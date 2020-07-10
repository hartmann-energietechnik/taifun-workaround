
# .pvprj ist ein einfaches Zip-Archiv

# Das Archiv wird extrahiert, und Sie können die Dateien im Archiv manuell ändern (Nur der Ornder /custom).

param (
    [string] $FilePath = "",
    [string] $Fileid = ""
)

$customFolder =  "$env:Temp\TaifunFiles\custom_$Fileid"
$tempFolderArchive =  "$env:Temp\TaifunFiles\" + [String] (Get-Random)

Copy-Item $FilePath "$FilePath.zip"
$FilePathZip = "$FilePath.zip"

Expand-Archive $FilePathZip -DestinationPath $tempFolderArchive
Remove-Item $FilePathZip -Force

New-Item $customFolder -itemtype directory
try {
    Copy-Item "$tempFolderArchive\custom\*" $customFolder
}
catch {}
try {
    Remove-Item "$tempFolderArchive\custom" -Force -Recurse
}
catch {}

."C:\Program Files\7-Zip\7z.exe" a -tzip "`"$FilePathZip`"" ("`"$tempFolderArchive\*`"")

Remove-Item $FilePath -Force
Copy-Item $FilePathZip $FilePath

Remove-Item $FilePathZip -Force
Remove-Item $tempFolderArchive -Force -Recurse


ii $customFolder