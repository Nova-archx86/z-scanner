{
  description = "Flake for z-scanner deps";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {self, nixpkgs}: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    devShells."x86_64-linux".default = pkgs.mkShell {
      buildInputs = with pkgs; [ zig_0_13 zon2nix ];
      shellHook = ''
        if [ -e $(which starship) ]; then
            eval "$(starship init bash)"
        fi
      ''; 
    };
    
  };
}
