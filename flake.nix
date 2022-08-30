{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # TODO: switch to original URI when #275 gets merged
    dream2nix.url = "github:tgunnoe/dream2nix/gitplus-version-fix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";

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
