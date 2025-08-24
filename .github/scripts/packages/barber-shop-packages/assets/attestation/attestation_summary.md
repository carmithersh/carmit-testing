# SLSA Provenance Attestation Summary

## Overview
This document contains the SLSA (Supply chain Levels for Software Artifacts) provenance attestation for the Docker image build.

## Attestation Details

### Subject Information
- **Type**: Docker Image Manifest
- **Name**: dixit-local/book-service/1/list.manifest.json
- **Digest**: 3fa6b968d0912409d22d7f647f2a944d28a955da8c2de1552b9c75d2e8b43547

### Build Information
- **Build Type**: GitHub Actions Workflow
- **Repository**: https://github.com/jfrogdixit/barbershop
- **Workflow Path**: .github/workflows/evidence.yml
- **Branch**: refs/heads/main

### Build Metadata
- **Event Name**: workflow_dispatch
- **Repository ID**: 1041388640
- **Runner Environment**: github-hosted

### Dependencies
- **Source Repository**: git+https://github.com/jfrogdixit/barbershop@refs/heads/main
- **Git Commit**: e6a05b222b858d6bfa3e6ad344a11af441172bf1

### Run Details
- **Builder ID**: https://github.com/jfrogdixit/barbershop/.github/workflows/evidence.yml@refs/heads/main
- **Invocation ID**: https://github.com/jfrogdixit/barbershop/actions/runs/17120744306/attempts/1

---
