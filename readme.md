# Quell-Datenbanken

Verzeichnis umfasst die Skripte, um die Quelldatenbanken in Docker hochzufahren

## Dumps restoren

Dump in gitignored/exchange ablegen, damit er via volume mount in den Containern unter /tmp verfügbar ist.

Container-Bash öffnen:

    #simi
    ./shsimi.sh

    #pub
    ./shpub.sh


Dump via Container-bash restoren:

    #simi
    pg_restore -d postgres -U postgres -O -x -C /tmp/simi_geodb-t.rootso.org.dmp

    #pub
    pg_restore -d postgres -U postgres -O -x -C /tmp/pub_geodb.rootso.org.dmp

# json2qgs Trafo installieren

## Venv erstellen und aktivieren

Virtuelle python Umgebung für json2qgs erstellen:

    python3 -m venv .gitignored/pipe_bin/jqgs/jqgs_venv

Venv aktivieren

    source .gitignored/pipe_bin/jqgs/jqgs_venv/bin/activate

Die aktive Python venv wird nun im Terminal ganz links angezeigt:

    (jqgs_venv) bjsvwjek@JOS:~/code/agi_wms$ 

## json2qgs "installieren"

Repo-Inhalt von json2qgs als *.zip herunterladen und in .gitignored kopieren (--> Beispielsweise Ordner "json2qgs-master")

Die notwendigen Bibliotheken für json2qgs im venv installieren

    pip install -r .gitignored/json2qgs-master/requirements.txt

Testhalber ausführen ohne Argumente

    python .gitignored/json2qgs-master/json2qgs.py

Aufruf und Antwort

    (jqgs_venv) bjsvwjek@JOS:~/code/agi_wms$ python .gitignored/json2qgs-master/json2qgs.py 
    Starting SO!GIS json2qgs...
    usage: json2qgs.py [-h] [--qgsTemplateDir [QGSTEMPLATEDIR]] [--log_level [{info,debug}]] qgsContent {wms,wfs} destination {2,3}
    json2qgs.py: error: the following arguments are required: qgsContent, mode, destination, qgisVersion

Todo:
* sourcepole
  * Angabe der benötigten Minimalversion von python
  * Packetierung des "executable" inlusive default qml, qgs (point, service_2, ...)
  * Relative Auflösung funktionert bei --qgsTemplateDir nicht
  * Hardcodierter Name des Ausgabe-qgs: Besser?: Name wird explizit angegeben.
  * Wo "landen" die assets?
  * Docku der Service-Images
    * QGIS Server
    * pg_services.conf: Telefonieren nach haus...?

# Ramp-Up

Die Migration von Config-DB und Config-Generator auf SIMI und Trafos betrifft alle Services der GDI. Die Komplexität des Gesamtsystems und der Datenmigration sind hoch.

Entsprechend macht es Sinn, die neue Umgebung bewusst in "baby-steps" hochzufahren. Das Verhalten des neuen Konfig-Deployments wird Testfall für Testfall und Service für Service
"hochgefahren"

## Testkonfigurationen

* Vec Einzellayer - Für sich publiziert (TEST 1)
* Vec Einzellayer - Nur via Facadelayer publiziert (TEST 2)
* Vec Einzellayer - Nur via Gruppenlayer publiziert (TEST 3)
* Facade von Vecs - Für sich publiziert (TEST 4)
* Facade von Vecs - Nur via Gruppenlayer publiziert (TEST 5)
* Vec Einzellayer - In Backgroundlayer publiziert (TEST 6)
* Facade von Vecs - In Backgroundlayer publiziert (TEST 7)
* Vec Einzellayer - Als zu löschen Markiert (TEST 8)

## Stand der Testfälle bzgl. der Services

Services (Später Spalten der Übersichtstabelle):

* WMS Standalone (WMSS)
* WFS Standalone (WFSS)
* WMS Cluster (WMSC)
* Dataservice (DS)
* Searchservice (SS)
* WFS Cluster (WFSC)
* WebGIS Client (WGC)
* CCC-Integration (CCC)
* SO-Locator (LOC)

Cross-Cutting: Map, Permissions