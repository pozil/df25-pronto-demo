#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

# Set parameters
ORG_ALIAS="pronto-scratch"

echo ""
echo "Installing Pronto org ($ORG_ALIAS)"
echo ""

echo "[1/11] Cleaning previous scratch org..."
sf org delete scratch -p -o $ORG_ALIAS &> /dev/null
echo ""

echo "[2/11] Cleaning previous agent metadata..."
node bin/clean-service-agent.js "force-app/main/default/aiAuthoringBundles/Customer_Service_Assistant/Customer_Service_Assistant.agent" && \
echo "" && \

echo "[3/11] Creating scratch org..." && \
sf org create scratch -f config/project-scratch-def.json -a $ORG_ALIAS -d -y 30 && \
echo "" && \

echo "[4/11] Creating agent user for service agent..." && \
agent_user=$(node bin/setup-service-agent.js --agent-file "force-app/main/default/aiAuthoringBundles/Customer_Service_Assistant/Customer_Service_Assistant.agent") && \
echo "" && \

echo "[5/11] Pushing source..." && \
sf project deploy start && \
echo "" && \

echo "[6/11] Assigning user permission set..." && \
sf org assign permset -n Merchant_Management_App && \
echo "" && \

echo "[7/11] Assigning agent permission set..." && \
sf org assign permset -n Customer_Service_Assistant --on-behalf-of "$agent_user" && \
echo "" && \

echo "[8/11] Importing sample data..." && \
sf data tree import -p data/data-plan.json && \
echo "" && \

echo "[9/11] Generating sample data: adding storefront thumbnails..." && \
sf apex run -f apex-scripts/set-storefront-thumbnails.apex && \
echo "" && \

echo "[10/11] Generating sample data: setting storefront operating hours..." && \
sf apex run -f apex-scripts/set-storefront-opening-hours.apex && \
echo "" && \

echo "[11/11] Opening org..." && \
sf org open -p lightning/page/home && \
echo ""
EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
  echo ""
else
    echo "Installation failed."
fi
exit $EXIT_CODE

