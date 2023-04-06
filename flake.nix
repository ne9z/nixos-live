{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11"; };

  outputs = { self, nixpkgs }@inputs:
    let lib = nixpkgs.lib;
    in {
      # time nix build .#nixosConfigurations.exampleHost.config.system.build.isoImage
      nixosConfigurations = {
        exampleHost = let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system};
        in lib.nixosSystem {
          inherit system;
          modules =
            [ (import ./configuration.nix { inherit inputs pkgs lib; }) ];
        };
      };
      ## This section is used to develop openzfs-docs,
      ## Not related to system configuration.
      devShells.x86_64-linux.default = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        sphinx-issues = let
          pname = "sphinx-issues";
          version = "3.0.1";
        in pkgs.python3Packages.buildPythonPackage {
          inherit pname version;
          src = pkgs.python3Packages.fetchPypi {
            inherit pname version;
            sha256 = "sha256-t8HcH0gIVjxFTRHBESeW+MF2zez+6V8P0jAu+Y4h49Y=";
          };
          doCheck = false;
          propagatedBuildInputs =
            builtins.attrValues { inherit (pkgs.python3Packages) sphinx; };
        };
        sphinx-notfound-page = let
          pname = "sphinx-notfound-page";
          version = "0.8.3";
        in pkgs.python3Packages.buildPythonPackage {
          inherit pname version;
          format = "pyproject";
          src = pkgs.python3Packages.fetchPypi {
            inherit pname version;
            sha256 = "sha256-9yhAMoACa4TCNFQL677X9xC56lguc0ijWlvs7+QCQzI=";
          };
          doCheck = false;
          propagatedBuildInputs = builtins.attrValues {
            inherit (pkgs.python3Packages) sphinx flit-core;
          };
        };
        pylit = let
          pname = "pylit";
          version = "0.8.0";
        in pkgs.python3Packages.buildPythonPackage {
          inherit pname version;
          format = "pyproject";
          src = pkgs.python3Packages.fetchPypi {
            inherit pname version;
            sha256 = "sha256-FXw6rHLHgpeCTYmD0pSDMdPD3+2DSQKWtIaU7eyoDwk=";
          };
          doCheck = false;
          propagatedBuildInputs =
            builtins.attrValues { inherit (pkgs.python3Packages) flit-core; };
        };
        python = pkgs.python3.withPackages (ps:
          builtins.attrValues {
            inherit (ps.pkgs.python3Packages)
              sphinx sphinx-rtd-theme setuptools;
            inherit sphinx-issues sphinx-notfound-page pylit;
          });
      in pkgs.mkShell {
        nativeBuildInputs = builtins.attrValues {
          inherit (pkgs) gnumake;
          inherit python;
        };
      };
    };
}
