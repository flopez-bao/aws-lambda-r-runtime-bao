#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

BASE_DIR=$(pwd)
BASE_VERSION=${VERSION:0:3}
ROUND_VERSION=$( printf '%.*f\n' 1 $BASE_VERSION )

if [[ 1 -eq "$(echo "$ROUND_VERSION >= 4.0" | bc)" ]]; then
   echo "Support currently not available for R 4 and up. Support is on the way..."
else
  echo "Building R runtimes for version: ${VERSION}..."
  ./docker_build.sh ${VERSION}
  cd ${BASE_DIR}/r
  ./build.sh ${VERSION}
  cd ${BASE_DIR}/runtime
  ./build.sh
  cd ${BASE_DIR}/dplyr
  ./build.sh ${VERSION}
  cd ${BASE_DIR}/recommended
  ./build.sh
  cd ${BASE_DIR}/awspack
  ./build.sh ${VERSION}
fi


