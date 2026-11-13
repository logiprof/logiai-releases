#!/bin/sh
# Installation / mise à jour de Logi AI web sur un site Node.js Infomaniak.
# À lancer dans la Console SSH du site :
#   curl -fsSL https://raw.githubusercontent.com/logiprof/logiai-releases/main/web/installer.sh | sh
set -e
SOURCE="${LOGIAI_SOURCE:-https://raw.githubusercontent.com/logiprof/logiai-releases/main/web/logiai-web.tar.gz}"

# Dossier du site : celui où l'on se trouve, ou un dossier « logiai.* » dans sites/.
CIBLE=""
if [ -f package.json ] && [ "$(pwd)" != "$HOME" ]; then CIBLE="$(pwd)"; fi
if [ -z "$CIBLE" ]; then
  for d in "$HOME"/sites/logiai.* /sites/logiai.* "$HOME"/logiai.*; do
    if [ -d "$d" ]; then CIBLE="$d"; break; fi
  done
fi
if [ -z "$CIBLE" ]; then
  echo "Dossier du site introuvable. Placez-vous d'abord dedans (cd sites/logiai.votredomaine.ch) puis relancez." >&2
  exit 1
fi
echo "Installation de Logi AI web dans : $CIBLE"
cd "$CIBLE"

TMP="$(mktemp -d)"
if command -v curl >/dev/null 2>&1; then curl -fsSL "$SOURCE" -o "$TMP/l.tgz"; else wget -qO "$TMP/l.tgz" "$SOURCE"; fi
mkdir "$TMP/x"
tar -xzf "$TMP/l.tgz" -C "$TMP/x"

# Les données (donnees/) ne sont jamais touchées.
rm -rf public serveur
cp -R "$TMP/x/public" "$TMP/x/serveur" .
cp "$TMP/x/package.json" "$TMP/x/LISEZMOI.txt" .
mkdir -p donnees && chmod 700 donnees
rm -rf "$TMP"

V="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' package.json | head -1)"
echo ""
echo "Logi AI web $V installé."
echo "Dernière étape : dans le Manager Infomaniak, page du site, cliquez sur « Redémarrer »."
