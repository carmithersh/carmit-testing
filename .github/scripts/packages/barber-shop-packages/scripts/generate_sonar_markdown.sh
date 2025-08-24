#!/bin/bash

# Generate Sonar Report Summary Markdown
# Usage: ./generate_sonar_markdown.sh <sonar_report_file> <output_markdown_file>

SONAR_REPORT_FILE="$1"
OUTPUT_MARKDOWN_FILE="$2"

if [ -z "$SONAR_REPORT_FILE" ] || [ -z "$OUTPUT_MARKDOWN_FILE" ]; then
    echo "Usage: $0 <sonar_report_file> <output_markdown_file>"
    exit 1
fi

if [ ! -f "$SONAR_REPORT_FILE" ]; then
    echo "Error: Sonar report file '$SONAR_REPORT_FILE' not found"
    exit 1
fi

# Extract values from JSON
CREATED_AT=$(cat "$SONAR_REPORT_FILE" | jq -r '.createdAt // "N/A"')
CREATED_BY=$(cat "$SONAR_REPORT_FILE" | jq -r '.createdBy // "N/A"')
PREDICATE_TYPE=$(cat "$SONAR_REPORT_FILE" | jq -r '.predicateType // "N/A"')

# Extract quality gate information
GATE_TYPE=$(cat "$SONAR_REPORT_FILE" | jq -r '.predicate.gates[0].type // "N/A"')
GATE_STATUS=$(cat "$SONAR_REPORT_FILE" | jq -r '.predicate.gates[0].status // "N/A"')
IGNORED_CONDITIONS=$(cat "$SONAR_REPORT_FILE" | jq -r '.predicate.gates[0].ignoredConditions')

# Convert ignored conditions to readable format
if [ "$IGNORED_CONDITIONS" = "true" ]; then
    IGNORED_CONDITIONS_DISPLAY="Yes"
elif [ "$IGNORED_CONDITIONS" = "false" ]; then
    IGNORED_CONDITIONS_DISPLAY="No"
else
    IGNORED_CONDITIONS_DISPLAY="$IGNORED_CONDITIONS"
fi

# Generate markdown from the sonar report
cat > "$OUTPUT_MARKDOWN_FILE" << EOF
# Sonar Quality Gate Report Summary

## Overview
This document contains the SonarQube quality gate analysis results for the codebase.

## Report Details

### General Information
- **Created At**: $CREATED_AT
- **Created By**: $CREATED_BY
- **Predicate Type**: $PREDICATE_TYPE

### Quality Gate Status
- **Gate Type**: $GATE_TYPE
- **Overall Status**: $GATE_STATUS
- **Ignored Conditions**: $IGNORED_CONDITIONS_DISPLAY

### Quality Conditions

EOF

# Extract and format each condition
CONDITIONS_COUNT=$(cat "$SONAR_REPORT_FILE" | jq '.predicate.gates[0].conditions | length')

for i in $(seq 0 $((CONDITIONS_COUNT - 1))); do
    STATUS=$(cat "$SONAR_REPORT_FILE" | jq -r ".predicate.gates[0].conditions[$i].status // \"N/A\"")
    METRIC_KEY=$(cat "$SONAR_REPORT_FILE" | jq -r ".predicate.gates[0].conditions[$i].metricKey // \"N/A\"")
    COMPARATOR=$(cat "$SONAR_REPORT_FILE" | jq -r ".predicate.gates[0].conditions[$i].comparator // \"N/A\"")
    ERROR_THRESHOLD=$(cat "$SONAR_REPORT_FILE" | jq -r ".predicate.gates[0].conditions[$i].errorThreshold // \"N/A\"")
    ACTUAL_VALUE=$(cat "$SONAR_REPORT_FILE" | jq -r ".predicate.gates[0].conditions[$i].actualValue // \"N/A\"")
    
    # Format metric key for better readability
    METRIC_NAME=$(echo "$METRIC_KEY" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
    
    # Convert comparator to readable format
    case "$COMPARATOR" in
        "GT") COMPARATOR_DISPLAY=">" ;;
        "LT") COMPARATOR_DISPLAY="<" ;;
        "GTE") COMPARATOR_DISPLAY=">=" ;;
        "LTE") COMPARATOR_DISPLAY="<=" ;;
        "EQ") COMPARATOR_DISPLAY="=" ;;
        *) COMPARATOR_DISPLAY="$COMPARATOR" ;;
    esac
    
    cat >> "$OUTPUT_MARKDOWN_FILE" << EOF
#### $METRIC_NAME
- **Status**: $STATUS
- **Metric**: $METRIC_KEY
- **Comparison**: $ACTUAL_VALUE $COMPARATOR_DISPLAY $ERROR_THRESHOLD

EOF
done

cat >> "$OUTPUT_MARKDOWN_FILE" << EOF
---
EOF

echo "Sonar markdown summary generated: $OUTPUT_MARKDOWN_FILE"
