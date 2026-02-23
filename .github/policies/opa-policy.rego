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

invalid_git_deps := [dep.uri |
	some node in evidence_nodes
	node.predicateType == "https://slsa.dev/provenance/v1"
	node.verified == true
	some dep in node.predicate.buildDefinition.resolvedDependencies
	startswith(dep.uri, "git+")
	not startswith(dep.uri, input.params.requiredGitOrgPrefix)
]

default result := {"allow": false, "missing": [], "message": "no evidence found"}

result := {"allow": true, "missing": [], "message": "all required evidence found and verified"} if {
	count(missing) == 0
	count(invalid_git_deps) == 0
}

result := {"allow": false, "missing": missing, "message": concat("", ["missing verified evidence for: ", concat(", ", missing)])} if {
	count(missing) > 0
}

result := {"allow": false, "missing": [], "message": concat("", ["SLSA provenance contains git dependencies from unauthorized sources: ", concat(", ", invalid_git_deps)])} if {
	count(missing) == 0
	count(invalid_git_deps) > 0
}
