{
  description = "Dev shell for the homebrew-tap repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      checks = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          git-hooks = git-hooks.lib.${system}.run {
            src = self;
            hooks = {
              nixfmt-rfc-style.enable = true;
              shellcheck.enable = true;
              shfmt.enable = true;
              convco.enable = true;
            };
          };
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              curl
              shellcheck
              shfmt
              convco
              nixfmt-rfc-style
            ];
            inherit (self.checks.${system}.git-hooks) shellHook;
          };
        }
      );
    };
}
