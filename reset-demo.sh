#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

echo "[1/3] Reset all local changes by reverting to git's latest commit"
rm -rf force-app/main/default/classes
rm -rf force-app/main/default/lwc
git reset --hard HEAD

echo "[2/3] Redeploy clean metadata"
sf project deploy start -c -g -m ApexClass -m LightningComponentBundle -m FlexiPage
echo ""

echo "[3/3] Remove metadata left overs (you can safely ignore any errors)"
sf project deploy start --manifest "reset-metadata/package.xml" --pre-destructive-changes "reset-metadata/destructiveChangesPre.xml" --purge-on-delete
echo ""

echo ""
echo Demo was reset. Remember to close all IDE tabs and clear dev agent history.
echo ""
