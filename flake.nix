{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        lib,
        pkgs,
        ...
      }:
        with pkgs; {
          devShells.default = mkShell {
            packages = [
              gcc
              zig
            ];
            shellHook = ''
              export AR="gcc-ar"
              exec ${lib.getExe nushell}
            '';
          };
        };
    };
}
