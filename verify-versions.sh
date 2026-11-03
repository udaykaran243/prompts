#!/bin/bash
set -euo pipefail

echo "Starting version consistency check..."

# Define file paths relative to the project root
GRADLE_FILE="gradle.properties"
CHART_FILE="Chart.yaml"
SNOW_FILE="snow-config.json"

# 1. Extract from gradle.properties (Format: version=1.3.4)
GRADLE_VER=$(grep '^version=' "$GRADLE_FILE" | cut -d= -f2 | tr -d '[:space:]')
echo "Gradle version: $GRADLE_VER"

# 2. Extract from Chart.yaml (Format: version: 1.3.4)
CHART_VER=$(yq eval '.version' "$CHART_FILE" | tr -d '[:space:]')
echo "Chart version:  $CHART_VER"

# 3. Extract from snow-config.json (Format: "description": "WPMP Services 1.3.4 ...")
# Uses regex to find the x.y.z pattern in the description string
SNOW_VER=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$SNOW_FILE" | head -n 1 | tr -d '[:space:]')
echo "Snow version:   $SNOW_VER"

# 4. Validate
if [ -z "$GRADLE_VER" ] || [ -z "$CHART_VER" ] || [ -z "$SNOW_VER" ]; then
  echo "❌ ERROR: One or more versions could not be parsed from the files."
  exit 1
fi

if [ "$GRADLE_VER" != "$CHART_VER" ] || [ "$GRADLE_VER" != "$SNOW_VER" ]; then
  echo "❌ VERSION MISMATCH DETECTED!"
  echo "Gradle: $GRADLE_VER | Chart: $CHART_VER | Snow: $SNOW_VER"
  echo "Please align the versions in gradle.properties, Chart.yaml, and snow-config.json before merging."
  exit 1
fi

echo "✅ SUCCESS: All versions are consistent ($GRADLE_VER)."
