{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        lib,
        pkgs,
        ...
      }: {
        devShells.default =
          pkgs.mkShell.override {
            stdenv = pkgs.clangStdenv;
          } {
            packages = with pkgs; [
              lldb
              zig_0_15
              zls_0_15
            ];
            shellHook = ''
              export AR="llvm-ar"
              exec ${lib.getExe pkgs.nushell}
            '';
          };
      };
    };
}
