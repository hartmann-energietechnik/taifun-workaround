
# (Unofficial) TAIFUN openDocuments - Workaround

Ein Workaround für TAIFUN openDocument mit dem nicht unterstützte Dateien (zB. .zip-Archive) geöffnet und versioniert werden können.

## Installieren und Einrichten
1. `taifun_open_files.exe` und `options.ini` von der [Release](https://github.com/otsmr/taifun-workaround/releases) Seite herunterladen
2. `options.ini` anpassen
```ini
# Es können mehrere Dateien getrennt durch ein ',' angegeben werden (kein Leerzeichen)
# Muster [Beginn der Datei]:[Dateiendung]
allowedfiles=PK:.zip,‰PNG:.png
```
4. `taifun_open_files.exe` und `options.ini` zB. in den Ornder `%AppData%\taifun-workaround` verschieben
3. Standardprogramm für `.txt` auf die Anwendung `%AppData%\taifun_open_files.exe` ändern

## Ablauf

**Datei ins Archiv hinzufügen**
1. Wenn noch nicht vorhanden: Neue Datei erstellen (zB. `test.zip`)
2. Dateiendung auf `.txt` ändern (zB. `test.zip.txt`)
3. Datei ins Archiv hinzufügen

**Datei aus dem Archiv öffnen (*Hintergrund*)**
1. `taifun_open_files.exe` wird gestartet
2. Es wird eine Kopie angelegt `{GUID}.txt` -> `%Temp%\TaifunFiles\{GUID}.[Erkannte Dateiendung]`
3. die Kopie wird als Child-Prozess von `taifun_open_files.exe` mit dem Standardprogramm geöffnet

**Datei wurde geändert und das Bearbeitungsprogramm geschlossen (*Hintergrund*)**

4. Die Originaldatei wird überschrieben: `%Temp%\TaifunFiles\{GUID}.[Erkannte Dateiendung]` -> `{GUID}.txt`
6. `taifun_open_files.exe` schließt sich automatisch 
7. TAIFUN erkennt die Beendigung des Child-Prozesses und zeigt die Optionen für die Versionierung im Falle einer Änderung an

## Fallback

Wenn eine .txt Datei mit `taifun_open_files.exe` geöffnet wird und der Parent-Process nicht `tfw.exe` heißt wird der Fallback gestartet. Standard ist notepad.exe.

```ini
fallback=C:\Windows\system32\notepad.exe
```

## TODO
* Erkennen der Dateiinhalte verbessern (Problem bei .pvprj und .zip (gleicher Anfang))
* Da TAIFUN die Datei wie ein Textdokument behandelt, an den Anfang der Datei einen Überblick über den Inhalt des Archiv einfügen
```txt
--------- Übersicht ---------

test.zip (Zip-Archiv)
│
│   README.md
│   taifun_open_files.cpp
│
├───.vscode
│       settings.json
│
└───tools
        ResourceHacker.exe

--------- Das ist alles, hören Sie ab hier auf zu bearbeiten! ---------
```