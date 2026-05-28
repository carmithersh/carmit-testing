package pr.policy

import rego.v1

# Flatten all objects under each repository key.
repo_entries := [entry |
	some repo_key in object.keys(input)
	some entry in input[repo_key]
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
	some approval in object.get(entry, "agents_approvals", [])
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
	"message": sprintf("missing valid agents_approvals.evidence for pre-merge commits: %s", [concat(", ", missing_pre_merge_commits)]),
} if {
	count(required_pre_merge_commits) > 0
	count(missing_pre_merge_commits) > 0
}

result := {
	"allow": true,
	"missing_pre_merge_commits": [],
	"message": "all pre-merge commits have valid agents_approvals.evidence",
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
