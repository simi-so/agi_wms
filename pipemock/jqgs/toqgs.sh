#!/bin/bash

source ../../.gitignored/pipe_bin/jqgs/jqgs_venv/bin/activate

python3 ../../.gitignored/pipe_bin/jqgs/json2qgs-master/json2qgs.py ../../.gitignored/pipe_data/qgs_wms/qgsContent.json wms ../../.gitignored/pipe_data/qgs_wms 2 --qgsTemplateDir /home/bjsvwjek/code/agi_wms/.gitignored/pipe_bin/jqgs/json2qgs-master/qgs
