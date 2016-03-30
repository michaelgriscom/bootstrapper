param (
    [string]$file,
    [long]$line,
    [long]$col
)

function Open-File-In-Devenv($file, $line, $col)
{
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
    $dte.MainWindow.Activate()
    $dte.ItemOperations.OpenFile($file)
    $dte.ActiveDocument.Selection.MoveToLineAndOffset($line, $col+1)
}

Open-File-In-Devenv (Resolve-Path $file).Path $line $col
