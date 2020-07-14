
# .pvprj ist ein einfaches Zip-Archiv

# Das Archiv wird extrahiert, und Sie können die Dateien im Archiv manuell ändern (Nur der Ornder /custom).

param (
    [string] $FilePath = "",
    [string] $Fileid = ""
)

$customFolder =  "$env:Temp\TaifunFiles\custom_$Fileid"
$tempFolderArchive =  "$env:Temp\TaifunFiles\" + [String] (Get-Random)

$FilePathZip = "$FilePath.zip"

Copy-Item $FilePath $FilePathZip

Expand-Archive $FilePathZip -DestinationPath $tempFolderArchive
Remove-Item $FilePathZip -Force


New-Item "$tempFolderArchive\custom" -itemtype directory
New-Item "$tempFolderArchive\custom\Screenshots\" -itemtype directory
try {
    Copy-Item "$customFolder\*" "$tempFolderArchive\custom"
    Copy-Item -Path "$tempFolderArchive\Visu3D\*.jpg"  -Destination "$tempFolderArchive\custom\Screenshots\" -exclude *Textur* -Recurse
}
catch {}

Write-Host $tempFolderArchive
Write-Host $FilePathZip

."C:\Program Files\7-Zip\7z.exe" a -tzip "`"$FilePathZip`"" ("`"$tempFolderArchive\*`"")

Remove-Item $FilePath -Force
Copy-Item $FilePathZip $FilePath

Remove-Item $FilePathZip -Force
Remove-Item $tempFolderArchive -Force -Recurse
Remove-Item $customFolder -Force -Recurse