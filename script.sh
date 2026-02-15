#!/bin/bash
set -e

echo "======================================"
echo "   Скрипт установки Arch Linux (XFCE)  "
echo "======================================"

# Проверка root
if [[ $EUID -ne 0 ]]; then
  echo "Запусти скрипт через sudo:"
  echo "sudo ./arch-setup.sh"
  exit 1
fi

USER_NAME=$SUDO_USER

echo
echo "Обновляем систему..."
pacman -Syu --noconfirm

# -------------------------------
# Русская локаль
# -------------------------------
echo
echo "Настраиваем русскую локаль..."

sed -i 's/^#\(ru_RU.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Язык системы оставляем английским
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Русская локаль добавлена."

# -------------------------------
# Русская клавиатура EN + RU
# -------------------------------
echo
echo "Настраиваем клавиатуру: EN + RU (Alt+Shift)..."

mkdir -p /etc/X11/xorg.conf.d

cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,ru"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
EOF

echo "Раскладки включены. Переключение: Alt+Shift"

# -------------------------------
# XFCE + LightDM
# -------------------------------
echo
echo "Устанавливаем XFCE4 и экран входа LightDM..."

pacman -S --noconfirm \
  xfce4 xfce4-goodies \
  lightdm lightdm-gtk-greeter \
  networkmanager

systemctl enable NetworkManager
systemctl enable lightdm

echo "XFCE4 и LightDM установлены."

# -------------------------------
# Установка yay
# -------------------------------
if ! command -v yay &> /dev/null; then
  echo
  echo "Устанавливаем yay (для AUR)..."

  pacman -S --noconfirm git base-devel

  sudo -u "$USER_NAME" git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay

  sudo -u "$USER_NAME" makepkg -si --noconfirm

  echo "yay установлен."
fi

# -------------------------------
# Функция установки пакетов
# -------------------------------
install_package() {
  local pkg="$1"
  local source="$2"

  read -p "Установить $pkg? (Y/N): " answer

  if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    echo "Устанавливаем $pkg..."

    if [[ "$source" == "pacman" ]]; then
      pacman -S --noconfirm "$pkg"
    else
      sudo -u "$USER_NAME" yay -S --noconfirm "$pkg"
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
echo
echo "======================================"
echo "Установка завершена!"
echo "Перезагрузи систему командой:"
echo "reboot"
echo "======================================"
