#!/usr/bin/env bash

# Herhangi bir komut hata verirse betiği durdur
set -e

if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

echo "--> Anahtar sunucularından GPG anahtarları çekiliyor..."
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x67BF8CA6DA181643C9723B4ED6C9442437365605" | gpg --import -
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xEF925EA60F33D0CB85C44AD13056513887B78AEB" | gpg --import -

echo "--> Anahtarlar pacman-key sistemine aktarılıyor ve imzalanıyor..."
gpg --export 67BF8CA6DA181643C9723B4ED6C9442437365605 | $SUDO pacman-key --add -
gpg --export EF925EA60F33D0CB85C44AD13056513887B78AEB | $SUDO pacman-key --add -

$SUDO pacman-key --lsign-key 67BF8CA6DA181643C9723B4ED6C9442437365605
$SUDO pacman-key --lsign-key EF925EA60F33D0CB85C44AD13056513887B78AEB

echo "--> Keyring ve Mirrorlist paketleri kuruluyor..."
$SUDO pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
$SUDO pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "--> pacman.conf dosyasına Chaotic-aur deposu ekleniyor..."
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | $SUDO tee -a /etc/pacman.conf
fi

echo "--> Sistem ve depolar güncelleniyor..."
$SUDO pacman -Syu --noconfirm

echo "Chaotic-aur başarılı bir şekilde sisteme kuruldu ve yapılandırıldı!"
