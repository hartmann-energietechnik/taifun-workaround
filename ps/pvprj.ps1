
# .pvprj ist ein einfaches Zip-Archiv

# .\pvprj.ps1 -sourceFile ".\test\full sim.pvprj" -saveFile "./test.json"

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

#  Wechselrichter

# E-Autos: Project.xml
# <ElektroAuto> {}
#   <Car> []
#       <ECarAndStationDBHersteller></ECarAndStationDBHersteller>
#       <ECarAndStationDBName></ECarAndStationDBName>
#       <AnzahlAutos></AnzahlAutos>
#       <GewuenschteReichweite> {}
#           <Value></Value>

param (
    [string] $sourceFile = "",
    [string] $saveFile = ""
)

$results = [pscustomobject] @{
    PVLeistung = ''
    Investitionskosten = ''
    Amortisationszeit = ''
    Wechselrichter = @()
    Module = @()
    Batteriesystem = [pscustomobject] @{
        Firma = ""
        Modell = ""
    }
    ElektroAuto = @()
};

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

$results.PVLeistung = ([String] $OecForeCastJSONData.PVLeistung) + " kWp";
$results.Investitionskosten = ([String] $OecForeCastJSONData.Investitionen.Data.Summe) + " Euro";
$results.Amortisationszeit = ([String] [Math]::Round($OecForeCastJSONData.ResultsModel.Data.Amortisationszeit, 2)) + " Jahre";


$ProjectXMLData = [xml] (Get-Content $ProjectXML)

if ($DBJSONData.Batteries.Length -eq 0) {
    $results.Batteriesystem.Firma = "Keine Batterie";
    $results.Batteriesystem.Modell = "-";
} else {
    $results.Batteriesystem.Firma = [String] $ProjectXMLData.PVData.Batteriesystem.Company.Value;
    $results.Batteriesystem.Modell = [String] $ProjectXMLData.PVData.Batteriesystem.SystemName.Value;

}


try {

    $ParametersNode = $ProjectXMLData.PVData.PVModule.SelectNodes('Modulfelder')

    foreach($Node in $ParametersNode){
        $results.Module += [pscustomobject] @{
            Dach = [String] $Node.Modulname[0]
            Hersteller = [String] $Node.ModulHersteller
            Name = [String] $Node.Modulname[1]
            Anzahl = [String]  $Node.Modulanzahl.Value
        }
    }
    
}
catch {}

try {

    $ParametersNode = $ProjectXMLData.PVData.Wechselrichter.Verschaltung.SelectNodes('WRObj')

    foreach($Node in $ParametersNode){
        $results.Wechselrichter += [pscustomobject] @{
            Hersteller = [String] $Node.InverterHersteller
            Modell = [String] $Node.InverterName
            Anzahl = [String] $Node.Haeufigkeit
        }
    }

}
catch {}


if ($DBJSONData.Batteries.Length -eq 0) {
} else {
    try {
        $ParametersNode = $ProjectXMLData.PVData.ElektroAuto.SelectNodes('Car')

        foreach($Node in $ParametersNode){
            $results.ElektroAuto += [pscustomobject] @{
                Hersteller = [String] $Node.ECarAndStationDBHersteller
                Modell = [String] $Node.ECarAndStationDBName
                Anzahl = [String] $Node.AnzahlAutos.Value
                Reichweite = [String] $Node.GewuenschteReichweite.Value + " km"
            }
        }
    }
    catch {}
}

function Format-Json {

    # https://stackoverflow.com/questions/56322993/proper-formating-of-json-using-powershell/56324939

    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    [int]$Indentation = 2;

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
        ForEach-Object {
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0)
            }

            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation
            }

            $line
        }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}



$Text = [String] ("PV*SOL Informationen`n" + ($results | convertto-json | Format-Json))

$output = $Text.Replace('ö','oe').Replace('ä','ae').Replace('ü','ue').Replace('ß','ss').Replace('Ö','Oe').Replace('Ü','Ue').Replace('Ä','Ae')
$isCapitalLetter = $Text -ceq $Text.toUpper()
if ($isCapitalLetter) { 
    $output = $output.toUpper() 
}


Set-Content -Path $saveFile -Value $output

# Aufräumen

Remove-Item $tempFolder -Recurse