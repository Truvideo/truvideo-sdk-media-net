#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-truvideo-sdk-media-net}"
SONAR_PROJECT_NAME="${SONAR_PROJECT_NAME:-truvideo-sdk-media-net}"
SONAR_HOST_URL="${SONAR_HOST_URL:?Set SONAR_HOST_URL to your SonarQube Server URL.}"
SONAR_TOKEN="${SONAR_TOKEN:?Set SONAR_TOKEN before running SonarQube analysis.}"
SOLUTION_FILE="${SOLUTION_FILE:-TruVideoMediaiOSBinding.sln}"
CONFIGURATION="${CONFIGURATION:-Release}"
SONAR_INCLUSIONS="${SONAR_INCLUSIONS:-}"
SONAR_EXCLUSIONS="${SONAR_EXCLUSIONS:-**/bin/**,**/obj/**,**/xcframeworks/**,**/*.xcframework/**,**/*.framework/**,**/*.dSYM/**,**/derivedData/**,**/archives/**}"

export PATH="$PATH:$HOME/.dotnet/tools"

if ! dotnet sonarscanner --version >/dev/null 2>&1; then
  dotnet tool install --global dotnet-sonarscanner
fi

SONAR_ARGS=(
  /k:"$SONAR_PROJECT_KEY" \
  /n:"$SONAR_PROJECT_NAME" \
  /d:sonar.host.url="$SONAR_HOST_URL" \
  /d:sonar.token="$SONAR_TOKEN" \
  /d:sonar.projectBaseDir="$ROOT_DIR" \
  /d:sonar.dotnet.excludeTestProjects=true \
  /d:sonar.scanner.scanAll=true \
  /d:sonar.exclusions="$SONAR_EXCLUSIONS"
)

if [[ -n "$SONAR_INCLUSIONS" ]]; then
  SONAR_ARGS+=(/d:sonar.inclusions="$SONAR_INCLUSIONS")
fi

dotnet sonarscanner begin "${SONAR_ARGS[@]}"

dotnet restore "$SOLUTION_FILE"
dotnet build "$SOLUTION_FILE" --configuration "$CONFIGURATION" --no-restore

dotnet sonarscanner end /d:sonar.token="$SONAR_TOKEN"
