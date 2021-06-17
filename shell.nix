{ pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];
  }
}:
with pkgs;
mkShell {
  buildInputs = [
    neovim-nightly
    nodePackages.prettier
    nixpkgs-fmt
    luaformatter
    luajitPackages.luacheck
    yamllint
    ripgrep
    fd
  ];

  shellHook = ''
    export XDG_DATA_DIRS=$XDG_DATA_DIRS:/etc/profiles/per-user/$USER/share
    alias nvim="nvim -u ${./init.lua}"
  '';
}
