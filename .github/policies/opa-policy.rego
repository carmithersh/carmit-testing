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

# SonarQube content checks

sonar_predicate_type := "https://sonarsource.com/evidence/sonarqube/v1"

default sonar_gate_ok := false

sonar_gate_ok if {
	some node in evidence_nodes
	node.predicateType == sonar_predicate_type
	node.verified == true
	some gate in node.predicate.gates
	gate.status == "OK"
}

default sonar_new_coverage_ok := false

sonar_new_coverage_ok if {
	some node in evidence_nodes
	node.predicateType == sonar_predicate_type
	node.verified == true
	some gate in node.predicate.gates
	some condition in gate.conditions
	condition.metricKey == "new_maintainability_rating"
	condition.status == "OK"
}

content_errors contains "SonarQube quality gate status is not OK" if {
	sonar_predicate_type in verified_types
	not sonar_gate_ok
}

content_errors contains "SonarQube new_coverage condition is not OK or missing" if {
	sonar_predicate_type in verified_types
	not sonar_new_coverage_ok
}

default result := {"allow": false, "missing": [], "message": "no evidence found"}

result := {"allow": true, "missing": [], "message": "all required evidence found and verified"} if {
	count(missing) == 0
	count(content_errors) == 0
}

result := {"allow": false, "missing": missing, "message": concat("; ", errors)} if {
	errors := array.concat(
		[concat("", ["missing verified evidence for: ", concat(", ", missing)]) | count(missing) > 0],
		[e | some e in content_errors],
	)
	count(errors) > 0
}
