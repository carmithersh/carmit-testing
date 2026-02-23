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

slsa_node := node if {
	some node in evidence_nodes
	node.predicateType == slsa_type
	node.verified == true
}

slsa_runner_ok if {
	slsa_node.predicate.buildDefinition.internalParameters.github.runner_environment == input.params.requiredRunnerEnv
}

slsa_org_ok if {
	startswith(slsa_node.predicate.buildDefinition.externalParameters.workflow.repository, input.params.requiredOrgPrefix)
}

slsa_ref_ok if {
	slsa_node.predicate.buildDefinition.externalParameters.workflow.ref == input.params.requiredRef
}

slsa_errors contains msg if {
	slsa_type in verified_types
	not slsa_runner_ok
	msg := sprintf("runner_environment is not '%s'", [input.params.requiredRunnerEnv])
}

slsa_errors contains msg if {
	slsa_type in verified_types
	not slsa_org_ok
	msg := sprintf("workflow repository does not start with '%s'", [input.params.requiredOrgPrefix])
}

slsa_errors contains msg if {
	slsa_type in verified_types
	not slsa_ref_ok
	msg := sprintf("workflow ref is not '%s'", [input.params.requiredRef])
}

default result := {"allow": false, "missing": [], "slsa_errors": [], "message": "no evidence found"}

result := {"allow": true, "missing": [], "slsa_errors": [], "message": "all required evidence found, verified, and compliant"} if {
	count(missing) == 0
	count(slsa_errors) == 0
}

result := {"allow": false, "missing": missing, "slsa_errors": [], "message": concat("", ["missing verified evidence for: ", concat(", ", missing)])} if {
	count(missing) > 0
}

result := {"allow": false, "missing": [], "slsa_errors": slsa_errors, "message": concat("", ["SLSA compliance failures: ", concat("; ", slsa_errors)])} if {
	count(missing) == 0
	count(slsa_errors) > 0
}
