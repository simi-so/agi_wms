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