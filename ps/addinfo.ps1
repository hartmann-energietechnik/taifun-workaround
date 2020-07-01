param (
    [string] $File = "",
    [string] $FileAdd = ""
)

$v = [IO.File]::ReadAllText($File, [text.encoding]::GetEncoding('IBM437'));
$FileAddContent = [IO.File]::ReadAllText($FileAdd, [text.encoding]::GetEncoding('IBM437'));


[System.IO.File]::WriteAllLines($File, ($FileAddContent + $v), [text.encoding]::GetEncoding('IBM437'));