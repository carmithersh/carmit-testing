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

slsa_nodes := [node |
	some node in evidence_nodes
	node.predicateType == slsa_type
	node.verified == true
]

slsa_runner_ok if {
	some node in slsa_nodes
	node.predicate.buildDefinition.internalParameters.github.runner_environment == "github-hosted"
}

slsa_ref_ok if {
	some node in slsa_nodes
	node.predicate.buildDefinition.externalParameters.workflow.ref == "refs/heads/main"
}

slsa_deps_ok if {
	some node in slsa_nodes
	deps := node.predicate.buildDefinition.resolvedDependencies
	count(deps) > 0
	every dep in deps {
		startswith(dep.uri, input.params.requiredGitOrgPrefix)
	}
}

slsa_content_ok if {
	slsa_runner_ok
	slsa_ref_ok
	slsa_deps_ok
}

slsa_content_failures contains "runner_environment is not github-hosted" if {
	not slsa_runner_ok
}

slsa_content_failures contains "workflow.ref is not refs/heads/main" if {
	not slsa_ref_ok
}

slsa_content_failures contains "resolvedDependencies contain URIs outside required GitHub org" if {
	not slsa_deps_ok
}

default result := {"allow": false, "missing": [], "message": "no evidence found"}

result := {"allow": true, "missing": [], "message": "all required evidence found and verified"} if {
	count(missing) == 0
	slsa_content_ok
}

result := {"allow": false, "missing": missing, "message": concat("", ["missing verified evidence for: ", concat(", ", missing)])} if {
	count(missing) > 0
}

result := {"allow": false, "missing": [], "message": concat("", ["SLSA content checks failed: ", concat(", ", slsa_content_failures)])} if {
	count(missing) == 0
	not slsa_content_ok
}
