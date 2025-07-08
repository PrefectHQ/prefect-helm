#!/usr/bin/env bash

set -e

# This script uses https://github.com/helm/chart-testing
# to run tests for our Helm Charts.
#
# It uses the Docker image to make it easier to run on local machines without
# having to manage the binary and its correct version.
#
# Dependencies:
# - docker
#
# Usage:
#  ./scripts/helm_charttest.sh

version=${VERSION:-v3.13.0}

# Lint each chart.
# Note: we'll skip validating maintainers, which doesn't play nicely
# in the Docker container. This will still run in CI.
for chart in worker server; do
  docker run \
    -it --rm \
    -v "$(pwd)":/code \
    -w /code \
    "quay.io/helmpack/chart-testing:${version}" \
    /bin/bash -c "ct lint --config .github/linters/${chart}-ct.yaml --validate-maintainers=false"
done
