#!/bin/bash

path="\
  $(pwd)/../../../.gitignored/pipe_bin/sql2json/sql2json.jar \
  -c jdbc:postgresql://localhost:5433/simi \
  -u postgres -p postgres \
  -t $(pwd)/template.json \
  -o $(pwd)/../../../.gitignored/pipe_data/finfo/featureInfoConfig.json \
  -s https://raw.githubusercontent.com/qwc-services/qwc-feature-info-service/master/schemas/qwc-feature-info-service.json \
  "
#echo $path

java -Dorg.slf4j.simpleLogger.defaultLogLevel=info -jar $path