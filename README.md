# Introduction
This is a simple nix flake template that aims to provide a simple barebones
working flutter template that comes with the androidSdk. Everything else I found 
across github simply weren't minimal enough to my liking.

Feel free to contribute or raise issues that may arise when using this template.
Have fun :D

# Instructions
The following will yeild a directory named my_new_project populated with the template
```sh
nix flake new my_new_project -t github:Rexcrazy804/flutter-nix-android-template
cd my_new_project
nix develop
```

## Setting up Android Virtual Device
Before we create the virtual device I recommend enabling kvm support by enabling the respective
kvm kernelmodule for your specific CPU. with the following nix option
```nix
boot.kernelModules = ["kvm-intel"]; # "kvm-amd" for amd cpus
```

Next add your user to the kvm group with like follows
```nix
users.users.rexies.extraGroups = [ "kvm"]; # replace rexies with your username
```

Once that is done cd back into the directory you have just created for the
flutter project and load the devShell using `nix develop` (I HIGHLY recommend
looking into [nix-direnv](https://github.com/nix-community/nix-direnv)) and execute the 
following commands

```sh
avdmanager create avd -n test -k "system-images;android-35;google_apis_playstore_ps16k;x86_64"
# you may run the above command without the -k "...." part to get the list of available platforms

flutter emulators --launch test
flutter run -d sdk
# don't forget flutter pub get if required
```

## Configuring adb
If you'd prefer wireless debugging on your android device you may enable adb as follows
```nix
programs.adb.enable = true;
users.users.rexies.extraGroups = [ "adbusers" ];
```

then pairing step would require the following comands
```sh
adb pair <deviceIP>:<paring-port> <pairing code>
adb connect <deviceIP>:<connection-port>
```
