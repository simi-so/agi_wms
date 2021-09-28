#!/bin/bash

# Zum Überspringen des OGC Service im Print-Service direkt den QGIS-Server konfigurieren: 
# "ogc_service_url": "http://qgs/ows/",

layers=ch.so.afu.gefahrenhinweiskarte_stfv%2Cch.so.afu.gewaesserschutz.zonen_areale
opacities=255%2C155

curl -X POST "http://localhost:5019/print/wms" \
  -H "accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "map0%3AGRID_INTERVAL_Y=500&map0%3AGRID_INTERVAL_X=500&map0%3AROTATION=0&map0%3AEXTENT=2632801.9%2C1242862.7%2C2633801.9%2C1244202.7&map0%3ASCALE=5000&map0%3ALAYERS=$layers&OPACITIES=$opacities&LAYERS=$layers&TRANSPARENT=true&FORMAT=pdf&TEMPLATE=A4%20hoch&SRS=EPSG%3A2056&DPI=200" \
  --output print.pdf
