#!/bin/bash

source ../../.gitignored/pipe_bin/jqgs/jqgs_venv/bin/activate

python3 ../../.gitignored/pipe_bin/jqgs/json2qgs-master/json2qgs.py \
  ../../.gitignored/pipe_data/qgs/qwc_print.json \
  wms \
  ../../.gitignored/pipe_data/qgs \
  2 \
  --qgsName qwc_print \
  --qgsTemplateDir ../../.gitignored/pipe_bin/jqgs/json2qgs-master/qgs
