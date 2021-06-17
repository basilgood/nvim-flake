{
  description = "neovim with config";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

  outputs = { self, nixpkgs, flake-utils, neovim-nightly-overlay }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      systems = [ "x86_64-linux" ];
      name = "initnvim";
      overlay = neovim-nightly-overlay.overlay;
      shell = ./shell.nix;
    };
}
