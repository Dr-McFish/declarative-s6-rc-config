# {stdenv, lib, execline, createCredentials, logDir, logDirUser ? "s6-log", logDirGroup ? "s6-log", forceDisableUserChange}:
let 
  pkgs = import <nixpkgs> {};
in
rec {
  # write an executable script file to /run. (Same as writeScript except the output is different)
  writeRunScript = name: text :
    pkgs.writeTextFile rec {
      inherit name text;
      destination = "/run";
      executable = true; 
    };

  createLongrunService = pkgs.callPackage ./longrun-service.nix {};
  createOneShotService = pkgs.callPackage ./oneshot-service.nix {};
  createServiceBundle = pkgs.callPackage ./service-bundle.nix {};
  lrctest = createLongrunService {
    name = "lrc-test";
    run = writeRunScript "lrc-test.run" ''
      haha
    '';
  };
}
