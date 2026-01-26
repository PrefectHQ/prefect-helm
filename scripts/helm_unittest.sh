#!/usr/bin/env bash

# This script uses https://github.com/helm-unittest/helm-unittest
# to run unit tests for our Helm Chart templates.
#
# Dependencies:
# - helm (can be installed via mise)
#
# Usage:
#  ./scripts/helm_unittest.sh

set -e

PLUGIN_VERSION=${PLUGIN_VERSION:-1.0.3}

# Check if helm-unittest plugin is installed
if ! helm plugin list | grep -q unittest; then
  echo "Installing helm-unittest plugin version ${PLUGIN_VERSION}..."
  helm plugin install https://github.com/helm-unittest/helm-unittest.git --version ${PLUGIN_VERSION} --verify=false
else
  echo "helm-unittest plugin is already installed"
fi

# Run helm unittest on all charts
helm unittest charts/*
