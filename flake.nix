{
  description = "A flake for Taconic bub client and server";
  inputs = {
    # We track the stable release as the default source for packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      overlayList = [ self.overlays.default ];
    in
    {
      overlays.default = final: prev: {
        bub = final.callPackage ./default.nix { };
      };

      nixosModules = {
        bub-server = import ./nixosModules/bub-server.nix {
          nixpkgs.overlays = overlayList;
        };
        default = self.nixosModules.bub-server;
      };

      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = overlayList;
          };
        in
        {
          bub = pkgs.bub;
          default = pkgs.bub;
        }
      );

      # DevShell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        }
      );

      nixosConfigurations = {
        # a test server
        container = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
          };
          modules = [
            ./nixosConfigurations/container.nix
            ./nixosModules/bub-server.nix
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  self.overlays.default
                ];
              }
            )
          ];
        };
      };
    };
}
