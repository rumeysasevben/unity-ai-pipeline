# Zips an Online Test Build folder for a playtester.
#   powershell -File tools\make-online-zip.ps1                      # the newest Builds\Online_* folder
#   powershell -File tools\make-online-zip.ps1 -Build Builds\Online_2026-11-11_1141
# Output: Builds\MyGame_Online_<yyyy-MM-dd>.zip, the build folder's own name as the zip's only top-level folder
# (as the earlier zips). Left out: "*_BurstDebugInformation_DoNotShip" (Unity's own name for it) and, unless -KeepD3D12, the D3D12
# folder (the Agility SDK Unity copies into every Windows build; the player draws with Direct3D 11 only, see the decision log).
param(
    [string]$Build = "",
    [string]$Zip = "",
    [switch]$KeepD3D12
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $PSScriptRoot
if ($Build -eq "") {
    $newest = Get-ChildItem (Join-Path $root "Builds") -Directory -Filter "Online_*" | Sort-Object Name | Select-Object -Last 1
    if ($null -eq $newest) { throw "No Builds\Online_* folder found." }
    $Build = $newest.FullName
}
$Build = (Resolve-Path $Build).Path.TrimEnd('\')
$top = Split-Path -Leaf $Build
if ($Zip -eq "") { $Zip = Join-Path $root ("Builds\MyGame_Online_{0:yyyy-MM-dd}.zip" -f (Get-Date)) }
if (Test-Path $Zip) { Remove-Item $Zip }

$files = Get-ChildItem $Build -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($Build.Length + 1)
    $first = $relative.Split('\')[0]
    -not ($first -like "*_BurstDebugInformation_DoNotShip") -and -not ((-not $KeepD3D12) -and $first -eq "D3D12")
}

$archive = [System.IO.Compression.ZipFile]::Open($Zip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        $entry = $top + "/" + $file.FullName.Substring($Build.Length + 1).Replace('\', '/')
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $entry, [System.IO.Compression.CompressionLevel]::Optimal)
    }
}
finally {
    $archive.Dispose()
}

$size = (Get-Item $Zip).Length
"{0}: {1} files, {2:N1} MB ({3:N0} bytes)" -f $Zip, @($files).Count, ($size / 1MB), $size
