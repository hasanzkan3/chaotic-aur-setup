#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

echo "--> Checking for pacman secret key..."
# If no secret key exists, initialize pacman-key
if ! $SUDO pacman-key --list-secret-keys &>/dev/null; then
  echo "--> Secret key not found. Initializing pacman-key..."
  $SUDO pacman-key --init
fi

echo "--> Fetching GPG keys from keyserver..."
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x67BF8CA6DA181643C9723B4ED6C9442437365605" | gpg --import -
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xEF925EA60F33D0CB85C44AD13056513887B78AEB" | gpg --import -

echo "--> Exporting keys to pacman-key and signing..."
gpg --export 67BF8CA6DA181643C9723B4ED6C9442437365605 | $SUDO pacman-key --add -
gpg --export EF925EA60F33D0CB85C44AD13056513887B78AEB | $SUDO pacman-key --add -

$SUDO pacman-key --lsign-key 67BF8CA6DA181643C9723B4ED6C9442437365605
$SUDO pacman-key --lsign-key EF925EA60F33D0CB85C44AD13056513887B78AEB

echo "--> Installing chaotic-keyring and chaotic-mirrorlist packages..."
$SUDO pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
$SUDO pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "--> Adding Chaotic-AUR repository to pacman.conf..."
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | $SUDO tee -a /etc/pacman.conf
fi

echo "--> Updating system and repositories..."
$SUDO pacman -Syu --noconfirm

echo "Chaotic-AUR repository has been successfully installed and configured!"
