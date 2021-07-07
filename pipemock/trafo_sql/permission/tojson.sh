#!/bin/bash

path="\
  $(pwd)/../../../.gitignored/pipe_bin/sql2json/sql2json.jar \
  -c jdbc:postgresql://localhost:5433/simi \
  -u postgres -p postgres \
  -t $(pwd)/template.json \
  -o $(pwd)/../../../.gitignored/pipe_data/ogc/permissions.json \
  -s https://github.com/qwc-services/qwc-services-core/raw/master/schemas/qwc-services-unified-permissions.json \
  "
#echo $path

java -Dorg.slf4j.simpleLogger.defaultLogLevel=info -jar $path