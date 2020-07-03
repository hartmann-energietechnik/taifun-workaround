
# (Unofficial) TAIFUN openDocuments - Workaround

Ein Workaround für TAIFUN openDocument, mit dem nicht unterstützte Dateien (z.B. .zip-Archive) geöffnet und versioniert werden können.
An der eigentlichen Software wird nichts verändert und es ist keine Installation notwendig.

## Features
* TAIFUN openDocument um die Unterstützung von Archiven erweitern
* Leicht erweiterbar durch Auslagerung von Code in PowerShell-Skripte
* Zusammenfassung des Dateiinhaltes  


![Screenshot](screenshot.png)
*Hier im Beispiel eine Simulation mit PV\*SOL Premium (.pvprj)*

## Installieren und Einrichten
1. `TAIFUN.Workaround.zip` von der [Release](https://github.com/otsmr/taifun-workaround/releases) Seite herunterladen
2. `TAIFUN.Workaround.zip` extrahieren und zB. in den Ornder `%AppData%\taifun-workaround` verschieben
3. `options.ini` anpassen
```ini
# PV*SOL Premium
addfile_ext=.pvprj
# Erste Zeichen in der Datei
addfile_firstChars=PK
# Dies muss in der ersten Zeile der Datei stehen
addfile_inLineOne=OecForeCast.json
# Die Zusammenfassung beginnt mit
addfile_infotitle=PV*SOL Informationen
# Skript zur Erstellung der Zusammenfassung
addfile_getinfo=pvprj.ps1
```
4. Standardprogramm für `.txt` auf die Anwendung `%AppData%\taifun-workaround\taifun_open_files.exe` ändern

## Ablauf

**Datei ins Archiv hinzufügen**
1. Wenn noch nicht vorhanden: Neue Datei erstellen (zB. `test.zip`)
2. Dateiendung auf `.txt` ändern (zB. `test.zip.txt`)
3. Datei ins Archiv hinzufügen

**Datei aus dem Archiv öffnen (*Hintergrund*)**
1. `taifun_open_files.exe` wird von TAIFUN gestartet (Da es das Standardprogramm von `.txt`-Dateien ist)
3. Wenn eine Zusammenfassung verfügbar ist, wird diese entfernt
2. Es wird eine Kopie angelegt `{GUID}.txt` -> `%Temp%\TaifunFiles\{GUID}.[Erkannte Dateiendung]`
3. die Kopie wird als Child-Prozess von `taifun_open_files.exe` mit dem eigentlichen Standardprogramm geöffnet

**Datei wurde geändert und das Bearbeitungsprogramm geschlossen (*Hintergrund*)**

4. Wenn in den `options.ini` ein PowerShell-Skript hinterlegt wurde, welches eine Zusammenfassung des Inhaltes erstellt, wird dieses nun ausgeführt
5. Wenn vorhanden wird die Zusammenfassung an den Anfang der Datei hinzugefügt
4. Die Originaldatei wird überschrieben: `%Temp%\TaifunFiles\{GUID}.[Erkannte Dateiendung]` -> `{GUID}.txt`
5. `taifun_open_files.exe` schließt sich automatisch 
6. TAIFUN erkennt die Beendigung des Child-Prozesses und zeigt die Optionen für die Versionierung im Falle einer Änderung an

## Fallback

Wenn eine `.txt`-Datei mit `taifun_open_files.exe` geöffnet wird und der Parent-Process nicht `tfw.exe` im Namen enthält wird diese mit dem Fallback geöffnet. Standard ist `notepad.exe`, kann aber über die `options.ini` geändert werden.

```ini
fallback=C:\Windows\system32\notepad.exe
```

## Development

Die `.cpp`-Dateien kann man zum Beispiel mit den [Visual Build Tools](https://visualstudio.microsoft.com/de/visual-cpp-build-tools/)  kompilieren.

Wenn diese installiert sind `build.bat` ausführen (ggf. muss der Pfad zu `vcvars64.bat` angepasst werden).

Über die `options.ini` kann ein Entwicklungsmodus gestartet werden, der es erleichtert, Fehler durch eine erweiterte Ausgabe leichter zu erkennen.
```ini
isDev=true
```

## Copyright & License

[MIT License](https://github.com/otsmr/win10settings/blob/master/LICENSE)  
Copyright (c) 2020  <a href="https://tsmr.eu">TSMR</a>