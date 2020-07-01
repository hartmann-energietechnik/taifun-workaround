param (
    [string] $File = "",
    [string] $toLineContent = ""
)

$v = [IO.File]::ReadAllText($File, [text.encoding]::GetEncoding('IBM437'));
$indexOf = $v.IndexOf($toLineContent) + $toLineContent.Length + 2;


$v = $v.Substring($indexOf, $v.Length - $indexOf)

[System.IO.File]::WriteAllLines($File, $v, [text.encoding]::GetEncoding('IBM437'));