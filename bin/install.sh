#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

# Set parameters
ORG_ALIAS="pronto-scratch"

echo ""
echo "Installing Pronto org ($ORG_ALIAS)"
echo ""

echo "Cleaning previous scratch org..."
sf org delete scratch -p -o $ORG_ALIAS &> /dev/null
echo ""

echo "Creating scratch org..." && \
sf org create scratch -f config/project-scratch-def.json -a $ORG_ALIAS -d -y 30 && \
echo "" && \

echo "Pushing source..." && \
sf project deploy start && \
echo "" && \

echo "Assigning permission sets..." && \
sf org assign permset -n Merchant_Management_App && \
echo "" && \

echo "Importing sample data..." && \
sf data tree import -p data/data-plan.json && \
echo "" && \

echo "Generating sample data: adding storefront thumbnails..." && \
sf apex run -f apex-scripts/set-storefront-thumbnails.apex && \
echo "" && \

echo "Generating sample data: setting storefront operating hours..." && \
sf apex run -f apex-scripts/set-storefront-opening-hours.apex && \
echo "" && \

echo "Opening org..." && \
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

