{
  description = "Project defaults from YoloDev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nix2container, ... }:
    {
      mkFlakeModule = apply: apply ./flake-module.nix { inherit nix2container; };
    };
}
