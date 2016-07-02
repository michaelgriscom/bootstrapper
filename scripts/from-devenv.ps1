# echo the current file, line, and column in VS so that emacs can pick it up

try
{
    # try to get dte for an existing instance of vs.
    $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject("VisualStudio.DTE")
}
catch
{
    # no vs instance up. start it
    $dte = New-Object -ComObject "VisualStudio.DTE"
    $dte.UserControl = $true # stick around after script is done
}
$path = $dte.ActiveDocument.FullName
$line = $dte.ActiveDocument.Selection.CurrentLine
$col = $dte.ActiveDocument.Selection.CurrentColumn

Write-Host "$path,$line,$col,"
