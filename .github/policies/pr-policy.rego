package pr.policy

import rego.v1

# Find repo entry objects regardless of where they are nested in input.
# A repo entry is expected to contain both commits and agents_reviews arrays.
repo_entries := [entry |
	some path, candidate in walk(input)
	is_object(candidate)
	commits := object.get(candidate, "commits", null)
	approvals := object.get(candidate, "agents_reviews", null)
	is_array(commits)
	is_array(approvals)
	entry := candidate
]

# All pre-merge commits that must be covered by approvals evidence.
required_pre_merge_commits := {commit_id |
	some entry in repo_entries
	some commit in object.get(entry, "commits", [])
	commit_id := object.get(commit, "pre_merge_commit", "")
	commit_id != ""
}

# Pre-merge commits that have at least one valid approvals evidence object.
approved_pre_merge_commits := {commit_id |
	some entry in repo_entries
	some approval in object.get(entry, "agents_reviews", [])
	commit_id := object.get(approval, "pre_merge_commit", "")
	commit_id != ""
	valid_evidence_payload(object.get(approval, "evidence", ""))
}

missing_pre_merge_commits := sort([commit_id |
	commit_id := required_pre_merge_commits[_]
	not commit_id in approved_pre_merge_commits
])

default result := {
	"allow": false,
	"missing_pre_merge_commits": [],
	"message": "no pre-merge commits found in input",
}

result := {
	"allow": false,
	"missing_pre_merge_commits": missing_pre_merge_commits,
	"message": sprintf("missing valid agents_reviews.evidence for pre-merge commits: %s", [concat(", ", missing_pre_merge_commits)]),
} if {
	count(required_pre_merge_commits) > 0
	count(missing_pre_merge_commits) > 0
}

result := {
	"allow": true,
	"missing_pre_merge_commits": [],
	"message": "all pre-merge commits have valid agents_reviews.evidence",
} if {
	count(required_pre_merge_commits) > 0
	count(missing_pre_merge_commits) == 0
}

valid_evidence_payload(evidence_str) if {
	is_string(evidence_str)
	evidence := json.unmarshal(evidence_str)
	evidence.schemaVersion == "1.0"
	evidence.type == "artifact"
	is_object(evidence.result)
	is_string(evidence.result.subjectRepoPath)
	is_array(evidence.result.evidence)
	count(evidence.result.evidence) > 0
}
