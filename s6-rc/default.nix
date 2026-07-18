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

  longrunService = pkgs.callPackage ./longrun-service.nix {};
  oneShotService = pkgs.callPackage ./oneshot-service.nix {};
  serviceBundle = pkgs.callPackage ./bundle.nix {};

  lrctest = longrunService {
    name = "lrc-test";
    run = writeRunScript "lrc-test.run" ''
      #!/bin/execlineb -P
      s6-sleep 60
      s6-false
    '';
  };
  osstest = oneShotService {
    name = "osstest";
    up = writeRunScript "osstest.run" ''
      #!/bin/execlineb -P
      s6-echo hehe
    '';
    down = writeRunScript "osstest.run" ''
      #!/bin/execlineb -P
      s6-echo itsjoverToT
    '';
  };
  sbtest = serviceBundle {
    name = "sbtest";
    contents = ["osstest" "lrctest"];
  };
}
