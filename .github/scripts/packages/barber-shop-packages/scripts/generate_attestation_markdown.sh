#!/bin/bash

# Generate SLSA Provenance Attestation Summary Markdown
# Usage: ./generate_attestation_markdown.sh <decoded_payload_file> <output_markdown_file>

DECODED_PAYLOAD_FILE="$1"
OUTPUT_MARKDOWN_FILE="$2"

if [ -z "$DECODED_PAYLOAD_FILE" ] || [ -z "$OUTPUT_MARKDOWN_FILE" ]; then
    echo "Usage: $0 <decoded_payload_file> <output_markdown_file>"
    exit 1
fi

if [ ! -f "$DECODED_PAYLOAD_FILE" ]; then
    echo "Error: Decoded payload file '$DECODED_PAYLOAD_FILE' not found"
    exit 1
fi

# Extract values from JSON first
SUBJECT_NAME=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.subject[0].name // "N/A"')
SUBJECT_DIGEST=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.subject[0].digest.sha256 // "N/A"')
REPOSITORY=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.externalParameters.workflow.repository // "N/A"')
WORKFLOW_PATH=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.externalParameters.workflow.path // "N/A"')
BRANCH=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.externalParameters.workflow.ref // "N/A"')
EVENT_NAME=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.internalParameters.github.event_name // "N/A"')
REPOSITORY_ID=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.internalParameters.github.repository_id // "N/A"')
RUNNER_ENV=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.internalParameters.github.runner_environment // "N/A"')
SOURCE_REPO=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.resolvedDependencies[0].uri // "N/A"')
GIT_COMMIT=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.buildDefinition.resolvedDependencies[0].digest.gitCommit // "N/A"')
BUILDER_ID=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.runDetails.builder.id // "N/A"')
INVOCATION_ID=$(cat "$DECODED_PAYLOAD_FILE" | jq -r '.predicate.runDetails.metadata.invocationId // "N/A"')

# Generate markdown from the decoded payload with actual values
cat > "$OUTPUT_MARKDOWN_FILE" << EOF
# SLSA Provenance Attestation Summary

## Overview
This document contains the SLSA (Supply chain Levels for Software Artifacts) provenance attestation for the Docker image build.

## Attestation Details

### Subject Information
- **Type**: Docker Image Manifest
- **Name**: $SUBJECT_NAME
- **Digest**: $SUBJECT_DIGEST

### Build Information
- **Build Type**: GitHub Actions Workflow
- **Repository**: $REPOSITORY
- **Workflow Path**: $WORKFLOW_PATH
- **Branch**: $BRANCH

### Build Metadata
- **Event Name**: $EVENT_NAME
- **Repository ID**: $REPOSITORY_ID
- **Runner Environment**: $RUNNER_ENV

### Dependencies
- **Source Repository**: $SOURCE_REPO
- **Git Commit**: $GIT_COMMIT

### Run Details
- **Builder ID**: $BUILDER_ID
- **Invocation ID**: $INVOCATION_ID

---
EOF

echo "Markdown summary generated: $OUTPUT_MARKDOWN_FILE"
