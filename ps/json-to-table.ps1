
Function ConvertFrom-JsonTable ($json) {

    $output = ""
    $width = 120
    $linetrenner = "|"
    for (($i = 0), ($j = 0); $i -lt $width - 2; $i++) { $linetrenner += "-" }
    $linetrenner += "| `n";

    $lineTrennerInLine = "| "
    for (($i = 0), ($j = 0); $i -lt ($width - 4); $i++) { $lineTrennerInLine += "-" }
    $lineTrennerInLine += " |`n"

    $lineTrennerSpace = "| "
    for (($i = 0), ($j = 0); $i -lt ($width - 4); $i++) { $lineTrennerSpace += " " }
    $lineTrennerSpace += " |`n"

    Function Get-Space11 ($count) {
        $space = "";

        for (($i = 0), ($j = 0); $i -lt $count; $i++) {
            $space += " "
        }
        $space;

    }

    Function Add-String ($item, $line = $true) {
        if ($line) {
            $tmp = $linetrenner
        }
        $space1 = Get-Space11 -count (30 - $item.Name.Length);
        $space2 = Get-Space11 -count (83 - $item.Value.Length);
        $tmp += "| " + $item.Name + $space1 + " | " + $item.Value + $space2 + " |`n";
        $tmp
    }

    $jsonMembers = $json.psobject.Members | where-object membertype -like 'noteproperty'

    ForEach ($1 in $jsonMembers) {

        if ($1.TypeNameOfValue -eq "System.String") {
            $output += Add-String -item $1
        }


        if ($1.TypeNameOfValue -eq "System.Management.Automation.PSCustomObject") {
            $output += $linetrenner
            $output += $lineTrennerSpace
            $space1 = Get-Space11 -count (111 - $1.Name.Length);
            $output += "| >> " + $1.Name.ToUpper()  + " <<" + $space1 + "|`n";
            $output += $lineTrennerSpace


            $2Members = $1.Value.psobject.Members | where-object membertype -like 'noteproperty'
            ForEach ($2 in $2Members) {
                $output += Add-String -item $2 -line $false
            }
            $output += $lineTrennerSpace

        }

        if ($1.TypeNameOfValue -eq "System.Object[]") {

            $columnWidth = @()

            ForEach ($2 in $1.Value[0]) {

                $2Members = $2.psobject.Members | where-object membertype -like 'noteproperty'
                # $output += $2Members.Length
                $output += "";
                $length = 0;
                ForEach ($3 in $2Members) {
                    
                    $space = Get-Space11 -count ($3.Value.Length + 3);
                    if ($3.Value.Length -lt $3.Name.Length) {
                        $space = Get-Space11 -count ($3.Name.Length + 3);
                    }

                    $add = "| " + $3.Name + $space;
                    $length += $add.Length;
                    $columnWidth += $add.Length


                    if ($columnWidth.Length -eq 1) {
                        $output += $linetrenner
                        $output += $lineTrennerSpace
                        $space1 = Get-Space11 -count (111 - $1.Name.Length);
                        $output += "| >> " + $1.Name.ToUpper()  + " <<" + $space1 + "|`n";
                        $output += $lineTrennerSpace
                    }
                    $output += $add;

                }
                $space = Get-Space11 -count (119 - $length);
                $output += $space + "|`n";

            }

            if ($columnWidth.Length -eq 0) { continue; }

            $output += $lineTrennerInLine;

            ForEach ($2 in $1.Value) {

            
                $2Members = $2.psobject.Members | where-object membertype -like 'noteproperty'
                # $output += $2Members.Length
                $output += "";
                $length = 0;
                $count = 0;
                ForEach ($3 in $2Members) {


                    $space = Get-Space11 -count ($columnWidth[$count] - $3.Value.Length - 2);

                    $add = "| " + $3.Value + $space;
                    $output += $add;
                    $length += $add.Length;
                    
                    $count++;


                }
                $space = Get-Space11 -count (119 - $length);
                $output += $space + "|`n";

            }
            $output += $lineTrennerSpace
            
        }
    }

    $output += $linetrenner
    return $output

}