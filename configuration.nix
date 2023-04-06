{ inputs, pkgs, lib, ... }:
let installerScript = pkgs.writeText "init.sh" (builtins.readFile ./init.sh);
in {

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = if (inputs.self ? rev) then
    inputs.self.rev
  else
    throw "refuse to build: git tree is dirty";

  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  users.users.root.initialPassword = lib.mkForce "test";
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  hardware.enableRedistributableFirmware = lib.mkForce false;

  services.getty.autologinUser = lib.mkForce "root";
  networking.wireless.enable = false;
  services.openssh = {
    enable = lib.mkDefault true;
    # settings = { PasswordAuthentication = lib.mkDefault false; };
    passwordAuthentication = true;
  };

  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  programs.git.enable = true;

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) mg # emacs-like editor
    ;
  };

  programs.bash.loginShellInit = "/root/init.sh";
  boot.postBootCommands = ''
    # Provide a mount point for nixos-install.
    mkdir -p /mnt

    cp ${installerScript} /root/init.sh
    chmod a+x /root/init.sh
  '';
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ]; # to start at boot
    serviceConfig.Restart = "always"; # restart when session is closed
  };

}
