# {stdenv, lib, execline, createCredentials, logDir, logDirUser ? "s6-log", logDirGroup ? "s6-log", forceDisableUserChange}:
let 
  pkgs = import <nixpkgs> {};
in
rec {
  #createLogServiceForLongRunService = import ./create-log-service-for-longrun-service.nix {
  #  inherit stdenv lib execline logDir logDirUser logDirGroup forceDisableUserChange;
  #};
  # write an executable script file to /run. 
  writeRunScript = name: text :
    pkgs.writeTextFile rec {
      inherit name text;
      destination = "/run";
      executable = true; 
    };

  createLongrunService = pkgs.callPackage ./create-longrun-service.nix {};
  createOneShotService = pkgs.callPackage ./create-oneshot-service.nix {};
  createServiceBundle = pkgs.callPackage ./create-service-bundle.nix {};
  lrctest = createLongrunService {
    name = "lrc-test";
    run = writeRunScript "lrc-test.run" ''
      haha
    '';
  };
}
