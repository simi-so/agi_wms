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

# Ramp-Up und Testfälle

Die Migration von Config-DB und Config-Generator auf SIMI und Trafos betrifft alle Services der GDI. Die Komplexität des Gesamtsystems und der Datenmigration sind hoch.

Entsprechend macht es Sinn, die neue Umgebung bewusst in "baby-steps" hochzufahren. Das Verhalten des neuen Konfig-Deployments wird Testfall für Testfall und Service für Service
"hochgefahren"

## Test-Szenarien

* WMS: Wird der WMS inklusive Permission's und Featureinfo korrekt konfiguriert?  
    Aspekte:
    * Featureinfo (Simpel und Komplex(MP). Vektor und Raster).
    * Permission (Public und "Private")
        * Auf DSV, Facadelayer und Layergruppen
* WGC: Funktionieren die von der Konfiguration betroffenen wichtigen Funktionen?
    * Suchen und Laden von Ebenen (DSV, Facadelayer und Layergruppen)
    * URL-Aufruf
        * Laden von ganzen Karten
        * Laden von Ebenen
    * Anzeige der Metainformationen (i)-Knopf
    * Print: Ebenen und Hintergrundkarten, Spezialprint "Plan für das Grundbuch"
    * Featureinfo
        * Simpel (Vektor und Raster)
        * Komplex(MP)
        * Anzeige von Objekt-Report(MP)
    * Editieren einer Ebene
    * CCC-Plugin am Beispiel BauGK(MP)
* Data-Service
    * Lesen von Zugriffsgeschützten Ebenen (xy.data)
    * "Where-Abfrage" auf die ID, für Ebene ohne weitere Attribute
* SO-Locator
    * Suchen und Laden von Ebenen (DSV, Facadelayer und Layergruppen)

Fragen:
* Data-Service: Soll dieser in der Pipeline zwingend aktiviert werden, wenn eine Objektsuche konfiguriert ist?






## Testkonfigurationen

### WMS (test.wms.*)

1. Vec Einzellayer - Für sich publiziert (TEST 1)
2. Vec Einzellayer - Nur via Facadelayer publiziert (TEST 2)
3. Vec Einzellayer - Nur via Gruppenlayer publiziert (TEST 3)
4. Facade von Vecs - Für sich publiziert (TEST 4)
5. Facade von Vecs - Nur via Gruppenlayer publiziert (TEST 5)
6. Vec Einzellayer - In Backgroundlayer publiziert (TEST 6)
7. Facade von Vecs - In Backgroundlayer publiziert (TEST 7)
8. Vec Einzellayer - Als zu löschen Markiert (TEST 8)

### Permissions (test.perm.*)

1. Public Einzellayer
1. Private Einzellayer
1. Public Facade
1. Private Facade
1. Public homo Group
1. Private hetero Group
1. Multiple private Children in Group
1. Dependeny permission

### Integration Permissions / WMS
1. Verhalten mit test.perm.3.main: Ein Kind ist als "zu löschen" markiert
1. Verhalten der Testfälle test.perm 1,2 und 4-6 wie erwartet? JA

### Print und External WM(T)S (test.prext.*)

1. GetMap-Request auf Background-Layer
1. GetMap-Request auf externen WMS
1. GetMap-Request auf externen WMTS
1. Alle obigen Testkonfigurationen kommen im "offiziellen" WMS und WFS Katalog (GetCapabilities ...) nicht vor.

### Feature Info (test.info.*)

1. DSV mit Feature-Report und special Featureinfo mit Sql-Query und spezieller Anzeige (Jinya)
1. Facadelayer mit einem Kind-DSV. Das DSV hat ein python-info hinterlegt

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

Migration+: Leere Strings

        /*
        SELECT
        *
        FROM
        simi.simi.simidata_table_field 
        WHERE
        wms_fi_format = ''
        */

        UPDATE 
        simi.simi.simidata_table_field 
        SET 
        wms_fi_format = NULL 
        WHERE
        wms_fi_format = ''



Todo:
* qgs aufteilen in die zwei pods print und "wms wfs"
* Weitermachen featureinfo: 
  * Klären, welche Konfiguration für das Standardverhalten überhaupt notwendig ist
  * Klären, wie das verhalten bezüglich Facadelayern (Gruppierungen) ist. Müssen alle Kinder eines Facadelayer konfigurirt sein?
  * Klären, ob eine sowohl im Facadelayer wie auch "für sich" konfiguriert sein muss.
  * Ticket schreiben zu allen feldern, welche base64 codiert werden sollen
* trafo_wms_dp_pubstate_v filtern auf published=true und published nicht mehr zurückgeben

simi:
* Template in spez fi muss wahrscheinlich nicht obligatorisch sein
* Geometriespalten manuell pflegbar machen
* Bug bei Export qml (binary gewurbel am Ende)
* Logging zurücksetzen

sql2json:
* Info-Logoutput der Ausgibt, welches template verarbeitet wird (mit Pfad) (-i)

Todo:
* Sortierung der Ebenen