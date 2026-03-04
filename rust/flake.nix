{
  description = "Project defaults from YoloDev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Binary cache from eigenvalue, so we do not follow nixpkgs
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      crate2nix,
      ...
    }:
    {
      mkFlakeModule = apply: apply ./flake-module.nix { inherit rust-overlay; };
    };
}
