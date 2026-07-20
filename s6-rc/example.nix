let 
  pkgs = import <nixpkgs> {};
in
rec {
  # Same as writeScript except the folder output is different

  longrunService = pkgs.callPackage ./longrun-service.nix {};
  oneShotService = pkgs.callPackage ./oneshot-service.nix {};
  serviceBundle = pkgs.callPackage ./bundle.nix {};

  lrctest = longrunService {
    name = "lrc-test";
    run = ''
      #!/bin/execlineb -P
      s6-sleep 60
      s6-false
    '';
    #flagEssential = true;
    #flagRecommended = true;
    finish = ''
      #!/bin/execlineb -P
      s6-echo done
    '';
    #dependencies = ["test1" "test231"];
    #notificationFd = 1337;
    #timeoutFinish = 6767;
    #timeoutKill = 29;
    #maxDeathTally = 1000;
    #downSignal = "weewoo";
    #data = pkgs.writeScriptBin "test.script" "aaaaa\n";
    #env = pkgs.writeScriptBin "test2.script" "aaaaa\n";
    #pipelinName = "hogwater";
  };

  osstest = oneShotService {
    name = "osstest";
    up = ''
      #!/bin/execlineb -P
      s6-echo hehe
    '';
    down = ''
      #!/bin/execlineb -P
      s6-echo itsjoverToT
    '';
    #flagEssential = true;
    #flagRecommended = true;
    #dependencies = ["test1" "test231"];
  };

  sbtest = serviceBundle {
    name = "sbtest";
    contents = ["osstest" "lrctest"];
    #flagEssential = true;
    #flagRecommended = true;
  };
}
