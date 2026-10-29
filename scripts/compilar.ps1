param(
    [Parameter(Mandatory = $true)][string]$Proyecto,
    [string]$Config = 'Debug'
)
# Compila un .dproj de Delphi 10.3 con msbuild. Devuelve codigo != 0 si falla.
$rsvars = 'C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\rsvars.bat'
if (-not (Test-Path $rsvars)) { Write-Error "No se encontro $rsvars"; exit 2 }
$ruta = (Resolve-Path $Proyecto).Path
$cmd = "call `"$rsvars`" && msbuild `"$ruta`" /t:Build /p:Config=$Config /p:Platform=Win32 /v:minimal /nologo"
cmd.exe /c $cmd
exit $LASTEXITCODE
