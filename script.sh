#!/bin/bash
set -e

# Проверка root
if [[ $EUID -ne 0 ]]; then
  echo "Run script using sudo:"
  echo "sudo ./arch-setup.sh"
  exit 1
fi

USER_NAME=$SUDO_USER

echo
echo "Обновляем систему..."
pacman -Syu --noconfirm

# -------------------------------
# XFCE + LightDM
# -------------------------------
echo
echo "Устанавливаем XFCE4 и LightDM..."

pacman -S --noconfirm --needed \
  xfce4 xfce4-goodies \
  lightdm lightdm-gtk-greeter \
  networkmanager

systemctl enable NetworkManager
systemctl enable lightdm

echo "XFCE и LightDM готовы."

# -------------------------------
# Включаем multilib (Steam)
# -------------------------------
echo
echo "Проверяем multilib (нужно для Steam)..."

if grep -q "^\#\[multilib\]" /etc/pacman.conf; then
  echo "Включаем multilib..."

  sed -i '/#\[multilib\]/,/#Include/ s/^#//' /etc/pacman.conf

  echo "Обновляем базы пакетов..."
  pacman -Sy --noconfirm

  echo "multilib включён."
else
  echo "multilib уже включён, пропускаем."
fi

# -------------------------------
# Установка yay
# -------------------------------
if ! command -v yay &> /dev/null; then
  echo
  echo "Installing yay (AUR helper)..."

  pacman -S --noconfirm --needed git base-devel

  sudo -u "$USER_NAME" git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay

  sudo -u "$USER_NAME" makepkg -si --noconfirm

  echo "yay установлен."
else
  echo "yay уже установлен, пропускаем."
fi

# -------------------------------
# Функция установки программ
# -------------------------------
install_package() {
  local pkg="$1"
  local source="$2"
  
echo

  read -p "Install $pkg? (y/n): " answer

  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    echo
    echo "Installing $pkg..."

    if [[ "$source" == "pacman" ]]; then
      pacman -S --noconfirm --needed "$pkg"
    else
      sudo -u "$USER_NAME" yay -S --noconfirm --needed "$pkg"
    fi
  fi
}

# -------------------------------
# Программы
# -------------------------------
echo
echo "======================================"
echo "Дополнительные программы:"
echo "======================================"

install_package "discord" "yay"
install_package "steam" "yay"
install_package "telegram-desktop" "pacman"
install_package "visual-studio-code-bin" "yay"
install_package "google-chrome" "yay"

# -------------------------------
# Завершение
# -------------------------------
reboot
