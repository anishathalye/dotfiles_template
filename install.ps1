$ErrorActionPreference = "Stop"

$CONFIG = "install.conf.yaml"
$DOTBOT_DIR = "dotbot"

$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

Set-Location $BASEDIR
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

foreach ($PYTHON in ('python', 'python3', 'python2')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (Invoke-Expression "![string]::IsNullOrWhiteSpace(`$($PYTHON -V))" 2>&1 -ErrorAction SilentlyContinue) { 
        &$PYTHON $(Join-Path $BASEDIR $DOTBOT_DIR $DOTBOT_BIN) -d $BASEDIR -c $CONFIG $Args 
        return
    }
}
Write-Error "Error: Cannot find Python." 
