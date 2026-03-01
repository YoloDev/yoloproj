{
  description = "Project defaults from YoloDev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    {
      mkFlakeModule = apply: apply ./flake-module.nix { };
    };
}
