if [[ -f "/etc/fedora-release" ]];
then
  sudo dnf install -y tilix NetworkManager-tui the_silver_searcher neovim tmux rofi arandr pavucontrol java-1.8.0-openjdk-devel feh compton fontawesome-fonts
  sudo dnf copr enable -y gregw/i3desktop
  sudo dnf install -y i3-gaps i3status i3lock
  sudo alternatives --set java java-1.8.0-openjdk.x86_64
  sudo dnf remove -y PackageKit-command-not-found
  pip3 install --user --upgrade pynvim
fi