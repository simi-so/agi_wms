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
  * Relative Auflösung funktionert bei --qgsTemplateDir
  * Hardcodierter Name des Ausgabe-qgs: Besser?: Name wird explizit angegeben.
  * Wo "landen" die assets?
  * Docku der Service-Images
    * QGIS Server