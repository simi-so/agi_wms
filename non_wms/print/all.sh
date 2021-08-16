#!/bin/bash

curl -X POST "http://localhost:5019/print/wms" \
  -H "accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "map0%3AGRID_INTERVAL_Y=50&map0%3AGRID_INTERVAL_X=50&map0%3AROTATION=0&map0%3AEXTENT=2607343.4%2C1227615.236%2C2607432.6%2C1227734.764&map0%3ASCALE=446&map0%3ALAYERS=ch.so.agi.hintergrundkarte.jo%2Cch.so.afu.wasserbewirtschaftung.quellen&OPACITIES=255%2C255&LAYERS=ch.so.agi.hintergrundkarte.jo%2Cch.so.afu.wasserbewirtschaftung.quellen&TRANSPARENT=true&FORMAT=pdf&TEMPLATE=A4%20hoch&SRS=EPSG%3A2056&DPI=200" \
  --output print.pdf