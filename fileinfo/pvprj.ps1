
# .pvprj ist ein einfaches Zip-Archiv

# ----- Informationen ------
# PV-Generatorenleistung: OecForeCast.json : PVLeistung (in kWp)
# Investitionskosten: OecForeCast.json : Investitionen.Data.Summe (in €)
# Amortisationszeit: OecForeCast.json : ResultsModel.Data.Amortisationszeit

# Moduleflächen: Project.xml
# <PVData> {}
#   <PVModule> []
#       <Modulfelder> []
#           <Modulname></Modulname>
#           <ModulHersteller></ModulHersteller>
#           <ModulName></ModulName>
#           <Modulanzahl></Modulanzahl>

# Batteriesystem: Project.xml
# <Batteriesystem> {}
#   <Company> {}
#       <Value></Value>
#   <SystemName> {}
#       <Value></Value>


# E-Autos: Project.xml
# <ElektroAuto> {}
#   <Car> []
#       <ECarAndStationDBHersteller></ECarAndStationDBHersteller>
#       <ECarAndStationDBName></ECarAndStationDBName>
#       <AnzahlAutos></AnzahlAutos>
#       <GewuenschteReichweite> {}
#           <Value></Value>

param (
    [string] $sourceFile = "";
    [string] $saveResults = "";
)

if ($sourceFile -eq "") exit;
if ($saveResults -eq "") exit;

$rand = Get-Random
$tempFolder =  "$env:Temp\TaifunFiles\PVSOL\$rand"

Copy-Item $sourceFile "$sourceFile.zip"
$sourceFile = "$sourceFile.zip"

Expand-Archive $sourceFile -DestinationPath $tempFolder
Remove-Item $sourceFile

$ProjectXML = "$tempFolder\Project.xml";
$OecForeCastJSON = "$tempFolder\OecForeCast.json";

if ((Test-Path -Path $ProjectXML) -ne $true ) exit;
if ((Test-Path -Path $OecForeCastJSON) -ne $true ) exit;

$xml = [xml] (Get-Content $ProjectXML)

$xml.PVData.Batteriesystem.Company.Value



# Aufräumen
Remove-Item $tempFolder -Recurse