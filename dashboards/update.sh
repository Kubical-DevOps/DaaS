#!/usr/bin/env bash

set -e
set -o pipefail

index='index.libsonnet'

cd $(dirname "$0")

if [ -f ${index} ]
then 
    rm ${index}
fi 

echo "{" >> ${index}
echo "  grafanaDashboards+:: {" >> ${index}

for file in `find . -name "*.json" -o -name "*.jsonnet" -o -name "*.libsonnet" -type f`; do
    if [ ${file} != "./${index}" ]
    then
        # Remove path
        filename=${file##*/}
        # Remove extension
        filenameNoExt=${filename%.*}
        echo "    '${filenameNoExt}.json': (import '${file}')," >> ${index}
    fi
done

echo "  }," >> ${index}
echo "}" >> ${index}
