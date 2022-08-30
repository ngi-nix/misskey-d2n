{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dream2nix.url = "github:nix-community/dream2nix";
    misskey = {
      url = "github:misskey-dev/misskey?submodules=true";
      flake = false;
    };
  };

  outputs = {self, nixpkgs, dream2nix, misskey}:
    (dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      packageOverrides = {};
      source = misskey;
    }) // {
      nixosModules.misskey = import ./nixosModule self;
      nixosModules.default = self.nixosModules.misskey;
    };
}
