#!/bin/bash

# Files in home
ln -sv ~/.dotfiles/home/.bashrc ~
ln -sv ~/.dotfiles/home/.bash_profile ~
ln -sv ~/.dotfiles/home/.bash_logout ~
ln -sv ~/.dotfiles/home/.gitconfig ~
ln -sv ~/.dotfiles/home/.minirc.dfl ~
ln -sv ~/.dotfiles/home/.gtkrc-2.0-kde4 ~
ln -sv ~/.dotfiles/home/.gdbinit ~
ln -sv ~/.dotfiles/home/.fonts.conf ~
ln -sv ~/.dotfiles/home/.excludes.gitignore ~

# Directories in home
ln -sv ~/.dotfiles/home/.bash_modules/ ~

# Files in .cargo
ln -sv ~/.dotfiles/home/.cargo/config.toml ~/.cargo/
ln -sv ~/.dotfiles/home/.cargo/clippy.toml ~/.cargo/

# Directories in .config
ln -sv ~/.dotfiles/home/.config/xsettingsd/ ~/.config/
ln -sv ~/.dotfiles/home/.config/uv/ ~/.config/
ln -sv ~/.dotfiles/home/.config/pip/ ~/.config/
ln -sv ~/.dotfiles/home/.config/includes/ ~/.config/
ln -sv ~/.dotfiles/home/.config/helix/ ~/.config/
ln -sv ~/.dotfiles/home/.config/halloy/ ~/.config/
ln -sv ~/.dotfiles/home/.config/gtk-4.0/ ~/.config/
ln -sv ~/.dotfiles/home/.config/gtk-3.0/ ~/.config/
ln -sv ~/.dotfiles/home/.config/gtk-2.0/ ~/.config/
ln -sv ~/.dotfiles/home/.config/fontconfig/ ~/.config/
ln -sv ~/.dotfiles/home/.config/fend/ ~/.config/
ln -sv ~/.dotfiles/home/.config/CrabFetch/ ~/.config/

# Files in .config
ln -sv ~/.dotfiles/home/.config/Trolltech.conf ~/.config/
ln -sv ~/.dotfiles/home/.config/starship.toml ~/.config/
ln -sv ~/.dotfiles/home/.config/shellcheckrc ~/.config/
ln -sv ~/.dotfiles/home/.config/plasmarc ~/.config/
ln -sv ~/.dotfiles/home/.config/ksplashrc ~/.config/
ln -sv ~/.dotfiles/home/.config/kscreenlockerrc ~/.config/
ln -sv ~/.dotfiles/home/.config/kdeglobals ~/.config/
ln -sv ~/.dotfiles/home/.config/kcminputrc ~/.config/

# Files in .config/VSCodium/User
ln -sv ~/.dotfiles/home/.config/VSCodium/User/settings.json ~/.config/VSCodium/User/
