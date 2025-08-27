function checkInternet {
	$google_reachable = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet
	$cloudflare_reachable = Test-Connection -ComputerName 1.1.1.1 -Count 1 -Quiet

	if ($google_reachable -or $cloudflare_reachable) {
		Write-Host "Internet Up"
		return $true
	}
	Write-Host "Internet Down"
	return $false
}

function checkTailscale {
	$tailscaleStatus = tailscale status 2>$null
    	if ($LASTEXITCODE -eq 0 -and $tailscaleStatus) {
		Write-Host "Tailscale Up"
		return $true
    	}        	
	Write-Host "Tailscale Down"
	return $false
}

function readyCheck {
    do {
        $net = checkInternet
        $ts = checkTailscale
        if (-not ($net -and $ts)) { Start-Sleep -Seconds 10 }
    } while (-not ($net -and $ts))
}

readyCheck

$bat = Join-Path $env:ProgramData 'datenpiloten\scripts\netzlaufwerke.cmd'

if (Test-Path $bat) {
  	& $bat
  	if ($LASTEXITCODE -ne 0) { Write-Error "Mount-Skript Fehler ($LASTEXITCODE)" }
} else {
  	Write-Error "Mount-Skript fehlt: $bat"
}