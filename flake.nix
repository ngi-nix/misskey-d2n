{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";

    misskey = {
      url = "github:misskey-dev/misskey/12.118.1?submodules=true";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    dream2nix,
    misskey,
  }:
    (dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      settings = [{translator = "yarn-lock";}];
      source = misskey;
      inject = {
        misskey."12.118.1" = [
          ["os-locale" "1.4.0"]
        ];
      };
      sourceOverrides = oldSources: {
        os-locale."1.4.0" = builtins.fetchTarball {
          # name = "os-locale-npm-1.4.0-924760b837-0161a1b6b5.zip";
          url = "https://registry.yarnpkg.com/os-locale/-/os-locale-1.4.0.tgz#20f9f17ae29ed345e8bde583b13d2009803c14d9";
          sha256 = "";
        };
      };
    })
    // {
      nixosModules.misskey = import ./nixosModule self;
      nixosModules.default = self.nixosModules.misskey;
    };
}
