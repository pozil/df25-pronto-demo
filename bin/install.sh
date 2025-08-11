#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

echo ""
echo "Installing Pronto demo org"
echo ""

echo "Pushing source..." && \
sf project deploy start && \
echo "" && \

echo "Assigning permission sets..." && \
sf org assign permset -n Merchant_Management_App && \
echo "" && \

echo "Updating sample data..." && \
sf apex run -f apex-scripts/assign-storefront-thumbnails.apex && \
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

