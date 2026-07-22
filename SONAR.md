# SonarQube Analysis

This repository uses `scripts/run-sonar.sh` for SonarQube analysis.

## GitHub Actions

Create these repository secrets before running `.github/workflows/sonarqube.yml`:

- `SONAR_HOST_URL`: SonarQube Server URL, for example `https://sonarqube.example.com`
- `SONAR_TOKEN`: project or user token with Execute Analysis permission

The workflow runs on `main`, `master`, `develop`, `prod-v**` branches, pull requests to those
branches, and manual dispatch.

SonarQube shows `Project's Main Branch is not analyzed yet` until an analysis is uploaded from the
branch configured as the project's main branch. For this repository, GitHub currently reports
`master` as the default branch, so run the workflow on `master` or merge this setup into `master`
before expecting the main project card to show its Quality Gate.

## Local Run

```sh
export SONAR_HOST_URL="https://sonarqube.example.com"
export SONAR_TOKEN="<token>"
./scripts/run-sonar.sh
```

Optional overrides:

- `SONAR_PROJECT_KEY`, default `truvideo-sdk-media-net`
- `SONAR_PROJECT_NAME`, default `truvideo-sdk-media-net`
- `SOLUTION_FILE`, default `TruVideoMediaiOSBinding.sln`
- `CONFIGURATION`, default `Release`
- `SONAR_INCLUSIONS`, optional source inclusion override, unset by default
- `SONAR_EXCLUSIONS`, default generated build output, bundled frameworks, symbols, and archives

The default source exclusion list is intentionally broad. This repository contains many vendored
`.xcframework` artifacts, so the scan excludes binary frameworks and generated build output while
letting the .NET scanner detect the binding project source files.
