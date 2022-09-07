{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";

    misskey = {
      url = "github:ngi-nix/misskey?submodules=true";
      flake = false;
    };

    node-gyp = {
      url = "github:nodejs/node-gyp/v9.1.0";
      flake = false;
    };

    libvips = {
      url = "https://github.com/lovell/sharp-libvips/releases/download/v8.13.1/libvips-8.13.1-linux-x64.tar.br";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    dream2nix,
    misskey,
    ...
  } @ inputs:
    (dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      packageOverrides = {
        "packages/client" = {
          add_misskey_path = {
            preBuild = ''
              ln -s ${misskey} misskey_root
            '';
            outputs = ["out" "client"];
          };
        };
        humanize-number.fix = {
          buildScript = "echo noBuild";
        };
        sharp.fix = {
          preBuild = ''
            mkdir v8.13.1
            ln -s ${inputs.libvips} v8.13.1/libvips-8.13.1-linux-x64.tar.br
            ls -la v8.13.1
          '';
          npm_config_sharp_libvips_local_prebuilds = "./";
          npm_package_config_libvips = "8.13.1";
        };
      };

      inject = {
        sharp."0.29.3" = [["node-gyp" "9.1.0"]];
      };
      sourceOverrides = oldSources: {
        node-gyp."9.1.0" = inputs.node-gyp;
      };

      source = misskey;
    })
    // {
      nixosModules.misskey = import ./nixosModule self;
      nixosModules.default = self.nixosModules.misskey;
    };
}
