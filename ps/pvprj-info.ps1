
# .pvprj ist ein einfaches Zip-Archiv

# .\pvprj-info.ps1 -sourceFile "..\test\pvsol.pvprj" -saveFile "./test.txt"

param (
    [string] $sourceFile = "",
    [string] $saveFile = ""
)

$output = "";

if ($sourceFile -eq "") {
    exit;
}
if ($saveFile -eq "") {
    exit;
}

$rand = Get-Random
$tempFolder =  "$env:Temp\TaifunFiles\PVSOL\$rand"

Copy-Item $sourceFile "$sourceFile.zip"
$sourceFile = "$sourceFile.zip"

Expand-Archive $sourceFile -DestinationPath $tempFolder
Remove-Item $sourceFile

$ProjectXML = "$tempFolder\Project.xml";
$SimResultsXML = "$tempFolder\SimResults.xml";
$OecForeCastJSON = "$tempFolder\OecForeCast.json";
$DBJSON = "$tempFolder\DB.json";

if ((Test-Path -Path $ProjectXML) -ne $true ) {
    exit;
}
if ((Test-Path -Path $OecForeCastJSON) -ne $true ) {
    exit;
}

$DBJSONData = Get-Content $DBJSON | Out-String | ConvertFrom-Json
$OecForeCastJSONData = Get-Content $OecForeCastJSON | Out-String | ConvertFrom-Json
$ProjectXMLData = [xml] (Get-Content $ProjectXML)
$SimResultsXMLData = [xml] (Get-Content $SimResultsXML -Encoding utf8)

$output += "`n>> Stammdaten <<`n";
$output += "PV-Generatorleistung: " + ([String] $OecForeCastJSONData.PVLeistung) + " kWp`n"
$output += "Investitionskosten: " + ([String] $OecForeCastJSONData.Investitionen.Data.Summe) + " Euro`n";
$output += "Inbetriebnahme Datum: " + ([String] $ProjectXMLData.PVData.ProjektdatenV1.InbetriebnahmeDatum.Value) + "`n";

$output += "`n>> Simulationsergebnisse <<`n";
$output += "Amortisationszeit: " + ([String] [Math]::Round($OecForeCastJSONData.ResultsModel.Data.Amortisationszeit, 2)) + " Jahre`n";
$output += "Spez. Jahresertrag: " + ([String] [Math]::Round($SimResultsXMLData.SimResultsXML.OffGridResults.SpezJahresErtrag.YearlyValue)) + " kWh/kWp`n";
$output += "Eigenverbrauchsanteil: " + ([String] [Math]::Round($SimResultsXMLData.SimResultsXML.VerbrauchResults.Eigenverbrauchsanteil.YearlyValue)) + " %`n";


try {

    $ParametersNode = $ProjectXMLData.PVData.PVModule.SelectNodes('Modulfelder')

    $output += "`n>> Modulfelder <<`n";

    foreach($Node in $ParametersNode){

        $output += "> " + [String] $Node.Modulname[0] + "`n";
        $output += "" +  [String]  $Node.Modulanzahl.Value + " " + [String] $Node.ModulHersteller + " " + [String] $Node.Modulname[1] + " " +  [String] $Node.InverterName + "`n";
        
    }
    
}
catch {}

try {

    $ParametersNode = $ProjectXMLData.PVData.Wechselrichter.Verschaltung.SelectNodes('WRObj')

    $output += "`n>> Wechselrichter <<`n";

    foreach($Node in $ParametersNode){

        $output += "> " + [String] $Node.Haeufigkeit + " " + [String] $Node.InverterHersteller + " " +  [String] $Node.InverterName + "`n";

    }

}
catch {}

if ($DBJSONData.Batteries.Length -ne 0) {
    $output += "`n>> Batterie <<`n";
    $output += [String] $ProjectXMLData.PVData.Batteriesystem.Company.Value + " " + [String] $ProjectXMLData.PVData.Batteriesystem.SystemName.Value + "`n";
}

if ($DBJSONData.CarsAndStations.Length -ne 0) {

     try {

        $output += "`n>> E-Auto <<`n";
        $ParametersNode = $ProjectXMLData.PVData.ElektroAuto.SelectNodes('Car')

        foreach($Node in $ParametersNode){
            $output += "> " + [String] $Node.AnzahlAutos.Value + " " + [String] $Node.ECarAndStationDBHersteller + [String] $Node.ECarAndStationDBName + " (" + [String] $Node.GewuenschteReichweite.Value + "km Reichweite)`n";
        }

    }
    catch {}
    
}

$Text = [String] ("PV*SOL Informationen`n" + $output)

$Text2 = $Text.Replace('ö','oe').Replace('ä','ae').Replace('ü','ue').Replace('ß','ss').Replace('Ö','Oe').Replace('Ü','Ue').Replace('Ä','Ae')

Set-Content -Path $saveFile -Value $Text2

Remove-Item $tempFolder -Recurse