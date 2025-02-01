{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: let 
        androidSdk = (pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "35.0.2";
          buildToolsVersions = [
            "30.0.3"
            "33.0.1"
            "34.0.0"
          ];
          platformVersions = [
            "31"
            "33"
            "34"
            "35"
          ];
          abiVersions = [ "x86_64" ];
          includeEmulator = true;
          emulatorVersion = "35.1.4";
          includeSystemImages = true;
          systemImageTypes = [ "google_apis_playstore" ];
          includeSources = false;
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
        }).androidsdk;
        androidEmu = pkgs.androidenv.emulateApp {
          name = "emulate-MyAndroidApp";
          platformVersion = "28";
          abiVersion = "x86"; # armeabi-v7a, mips, x86_64
          systemImageType = "google_apis_playstore";
        };
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            jdk17
            aapt
          ] ++ [androidSdk androidEmu];

          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/34.0.0/aapt2";
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        };
      };
      flake = {};
    };
}
