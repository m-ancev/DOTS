{ config, pkgs, ... }:

let
  user = "ma";
in

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.wireless.iwd.enable = true;  # Enables wireless support
  networking.useDHCP = true;
  # networking.networkmanager.enable = true: # Fallback in case of issues
 
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Sound
  # Enable PipeWire with ALSA, PulseAudio compatibility, and WirePlumber
  services.pipewire = {
    enable = true;
    alsa.enable = true;        # Enables ALSA support
    pulse.enable = true;       # Enables PulseAudio compatibility
    jack.enable = true;        # Enables JACK support (optional)
    wireplumber.enable = true; # Enables WirePlumber as the session manager
  };

  # Ensure ALSA state persistence across reboots
  hardware.alsa.enablePersistence = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable udisks2 for managing USB drives and auto-mounting
  services.udisks2.enable = true;

  # Optional: Polkit rule to allow USB auto-mounting for "wheel" group users.
  # Uncomment if future permission issues occur:
  #
  # security.polkit.extraRules = ''
  #   polkit.addRule(function(action, subject) {
  #       if (action.id == "org.freedesktop.udisks2.filesystem-mount" &&
  #           subject.isInGroup("wheel")) {
  #           return polkit.Result.YES;
  #       }
  #   });
  # '';
  #

  # Notes:
  # - USB auto-mounting works out of the box for "wheel" group users.
  # - Polkit configuration is omitted for now but can be added for clarity
  #   or if permission issues arise with future users or specific devices.

  # To add a user to the "wheel" group:
  #   sudo usermod -aG wheel <username>
  # Log out and back in to apply group changes.

  # Needed for an app idk yet
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # Automatic garbage collection
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Automatically upgrade when rebuilding using channel
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };

  # Define a user account.
  users.users.${user} = {
    isNormalUser = true;
    description = "ma";
    extraGroups = [ "networkmanager" "wheel" "audio" "video"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.unstable = true;


  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    firefox
    kitty
    tldr
    keepassxc
    obsidian
    syncthing
    unzip
    ripgrep
    htop
    btop
    tmux
    thunderbird
    lazygit
    tree
    tofi
    iwd
    fzf
    sublime-merge
    nautilus
    udiskie
    python3
    lua
    tree-sitter
    fd
    gnumake
    gcc
    luajitPackages.luarocks
    python311Packages.pip
    nodejs_22
    grim
    slurp
    wl-clipboard
    mako
    swaylock-effects
    pavucontrol  # GUI for volume control
    pamixer      # CLI for volume control
  ];

  services.gnome.gnome-keyring.enable = true;
  
  # Set up Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };

  # Set up Font
  fonts.packages = [ pkgs.jetbrains-mono ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
