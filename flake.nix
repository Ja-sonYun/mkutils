{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      utilsMk =
        pkgs:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "mkutils-mk";
          version = "0.1.0";
          src = builtins.path {
            path = ./.;
            name = "source";
          };
          buildPhase = "bash build.sh";
          installPhase = ''
            mkdir -p $out/share/mkutils
            cp dist/utils.mk $out/share/mkutils/utils.mk
          '';
        };

      mkutilsMake =
        pkgs:
        pkgs.writeShellScriptBin "make" ''
          export MAKEFILES="${utilsMk pkgs}/share/mkutils/utils.mk''${MAKEFILES:+ $MAKEFILES}"
          exec ${pkgs.gnumake}/bin/make "$@"
        '';
    in
    {
      overlays.default = final: _prev: {
        mkutils = mkutilsMake final;
      };

      packages = forAllSystems (pkgs: {
        default = mkutilsMake pkgs;
        utils-mk = utilsMk pkgs;
      });

      checks = forAllSystems (pkgs: {
        pre-commit-check = git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
          src = ./.;
          excludes = [
            "^dist/"
            "^flake\\.lock$"
          ];
          hooks = {
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            prettier.enable = true;
            beautysh = {
              enable = true;
              name = "beautysh";
              package = pkgs.beautysh;
              entry = "${pkgs.beautysh}/bin/beautysh --tab";
              types = [ "shell" ];
              excludes = [ "\\.bats$" ];
            };
          };
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) shellHook;
          packages =
            (with pkgs; [
              (bats.withLibraries (p: [
                p.bats-support
                p.bats-assert
              ]))
              gnumake
            ])
            ++ self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check.enabledPackages;
        };
      });
    };
}
