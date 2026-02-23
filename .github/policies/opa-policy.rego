package evidence.policy

import rego.v1

evidence_nodes := [node | some edge in input.evidence; node := edge.node]

verified_types := {node.predicateType |
	some node in evidence_nodes
	node.verified == true
}

missing := [pt |
	some pt in input.params.predicateTypes
	not pt in verified_types
]

slsa_type := "https://slsa.dev/provenance/v1"

slsa_verified_nodes := [node |
	some node in evidence_nodes
	node.predicateType == slsa_type
	node.verified == true
]

default slsa_github_runner_ok := false

slsa_github_runner_ok if {
	some node in slsa_verified_nodes
	contains(node.predicate.runDetails.builder.id, "github.com")
}

default slsa_org_ok := false

slsa_org_ok if {
	some node in slsa_verified_nodes
	some dep in node.predicate.buildDefinition.resolvedDependencies
	startswith(dep.uri, input.params.requiredGitOrgPrefix)
}

slsa_content_failures := array.concat(
	[msg | not slsa_github_runner_ok; msg := "SLSA builder is not a GitHub runner"],
	[msg | not slsa_org_ok; msg := concat("", ["source repo not under required GitHub org: ", input.params.requiredGitOrgPrefix])],
)

default result := {"allow": false, "missing": [], "message": "no evidence found"}

result := {"allow": true, "missing": [], "message": "all required evidence found and verified"} if {
	count(missing) == 0
	count(slsa_content_failures) == 0
}

result := {"allow": false, "missing": missing, "message": concat("", ["missing verified evidence for: ", concat(", ", missing)])} if {
	count(missing) > 0
}

result := {"allow": false, "missing": [], "message": concat("; ", slsa_content_failures)} if {
	count(missing) == 0
	count(slsa_content_failures) > 0
}
