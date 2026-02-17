/#!/bin/bash
set -e

# запрос пароля только 1 раз от юзера
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &


# Проверка root
if [[ $EUID -eq 0 ]]; then
  echo "Run script WITHOUT sudo:"
  echo "sh ./arch-setup.sh"
  exit 1
fi

#запись имени юзера в переменную USER_NAME
USER_NAME=$whoami

echo
echo ------------------------------------
echo "***** Updating OS using pacman *****"
echo ------------------------------------
echo
sudo pacman -Syu --noconfirm

echo
echo ----------------------------------------
echo "***** Installing XFCE4 and LightDM***** "
echo ----------------------------------------
echo

sudo pacman -S --noconfirm --needed \
  xfce4 xfce4-goodies \
  lightdm lightdm-gtk-greeter

#включаем в автозагрузку экран блокировки
systemctl enable lightdm

echo
echo -----------------------------
echo "check multilib (for Steam)..."
echo -----------------------------
echo

if grep -q "^\#\[multilib\]" /etc/pacman.conf; then
  echo
  echo "Enabling multilib..."
  echo
  sudo sed -i '/#\[multilib\]/,/#Include/ s/^#//' /etc/pacman.conf

  echo "Updating package databases (from miltilib)"
  sudo pacman -Sy --noconfirm

  echo "multilib enabled!"
else
  echo "multilib already enabled, skipping"
fi

# -------------------------------
# Установка yay
# -------------------------------
if ! command -v yay &> /dev/null; then
  echo
  echo ------------------------------------------
  echo "***** Installing yay (AUR helper)... *****"
  echo ------------------------------------------
  echo

  sudo pacman -S --noconfirm --needed base-devel

  sudo -u "$USER_NAME" git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay

  sudo -u "$USER_NAME" makepkg -si --noconfirm

  echo "yay installed."
else
  echo "yay installed already."
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
    echo ---------------------------------
    echo "***** INSTALLING $pkg *****"
    echo ---------------------------------
    echo
    if [[ "$source" == "pacman" ]]; then
      pacman -S --noconfirm --needed "$pkg"
    else
      sudo -u "$USER_NAME" yay -S --noconfirm --needed "$pkg"
    fi
  fi
}

echo
echo ---------------------------
echo "Installing additional apps:"
echo ---------------------------
echo

install_package "discord" "yay"
install_package "steam" "yay"
install_package "telegram-desktop" "pacman"
install_package "visual-studio-code-bin" "yay"
install_package "google-chrome" "yay"

reboot
