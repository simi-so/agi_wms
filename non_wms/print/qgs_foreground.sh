#!/bin/bash

curl -X POST "http://localhost:8081/ows/qwc_print" \
  -H "accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "SERVICE=WMS&VERSION=1.3.0&REQUEST=GetPrint&MAP0%3AGRID_INTERVAL_Y=50&MAP0%3AGRID_INTERVAL_X=50&MAP0%3AROTATION=0&MAP0%3AEXTENT=2607343.4%2C1227615.236%2C2607432.6%2C1227734.764&MAP0%3ASCALE=446&MAP0%3ALAYERS=ch.so.agi.bezirksgrenzen&OPACITIES=255&LAYERS=ch.so.agi.bezirksgrenzen&TRANSPARENT=true&FORMAT=pdf&TEMPLATE=A4+hoch&SRS=EPSG%3A2056&DPI=200" \
  --output print.pdf