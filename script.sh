#!/bin/bash
set -e

echo "=== Arch Setup Script ==="

# Проверка root
if [[ $EUID -ne 0 ]]; then
  echo "Запусти скрипт через sudo:"
  echo "sudo ./arch-setup.sh"
  exit 1
fi

echo
echo "Обновляем систему..."
pacman -Syu --noconfirm

echo
echo "Устанавливаем XFCE4 и дисплей-менеджер LightDM..."

pacman -S --noconfirm \
  xfce4 xfce4-goodies \
  lightdm lightdm-gtk-greeter \
  networkmanager

echo
echo "Включаем NetworkManager..."
systemctl enable NetworkManager

echo
echo "Включаем LightDM (экран входа)..."
systemctl enable lightdm

echo
read -p "Установить Discord? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  echo
  echo "Устанавливаем yay (для AUR)..."

  # Ставим нужные инструменты
  pacman -S --noconfirm git base-devel

  # Создаём временную папку
  cd /tmp

  # Скачиваем yay
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm

  echo
  echo "Устанавливаем Discord..."
  sudo -u "$SUDO_USER" yay -S --noconfirm discord

fi

echo
echo "Готово. Перезагрузи систему командой:"
echo "reboot"
