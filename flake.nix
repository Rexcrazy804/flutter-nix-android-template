{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        sdkArgs = {
          toolsVersion = "26.1.1";
          platformToolsVersion = "35.0.2";
          buildToolsVersions = ["30.0.3" "33.0.1" "34.0.0"];
          # in the event flutter complains about requireing additional
          # platform versions, just add them here
          platformVersions = ["34" "35"];
          abiVersions = ["x86_64"];
          includeEmulator = true;
          emulatorVersion = "35.1.4";
          includeSystemImages = true;
          systemImageTypes = ["google_apis_playstore"];
          includeSources = false;

          # uncomment as required
          extraLicenses = [
            # "android-googletv-license"
            # "android-sdk-arm-dbt-license"
            # "android-sdk-license"
            # "android-sdk-preview-license"
            # "google-gdk-license"
            # "intel-android-extra-license"
            # "intel-android-sysimage-license"
            # "mips-android-sysimage-license"
          ];
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages sdkArgs;
        androidSdk = androidComposition.androidsdk;
        platformTools = androidComposition.platform-tools;
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        formatter = pkgs.alejandra;

        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell {
          packages = with pkgs;
            [
              flutter
              jdk17
              chromium
            ]
            ++ [
              androidSdk
              platformTools
            ];

          CHROMIUM_EXECUTABLE = "${pkgs.chromium}/bin/chromium";
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/34.0.0/aapt2";
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        };
      };

      flake = {
        templates = rec {
          flutter = {
            path = ./.;
            description = "A simple flutter template to sit up flutter androidSDK + chrome";
            welcomeText = ''
              # Welcome to nixos Flutter Template
              yipeeeeeee!!!!
            '';
          };
          default = flutter;
        };
      };
    };
}
