{ inputs, pkgs, lib, ... }: {

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

  users.users = { root = { initialPassword = lib.mkForce "test"; }; };

  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  hardware.enableRedistributableFirmware = lib.mkForce false;

  services.openssh = {
    enable = lib.mkDefault true;
    # settings = { PasswordAuthentication = lib.mkDefault false; };
    passwordAuthentication = true;
    permitRootLogin = "yes";
  };

  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  programs.git.enable = true;

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) mg # emacs-like editor
    ;
  };
}
