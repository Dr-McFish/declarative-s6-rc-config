{ lib, symlinkJoin, runCommand
, writeTextFile }:
let
  s6-rc-setting = import ../create-s6-setting.nix {
    inherit lib runCommand symlinkJoin writeTextFile;
  };
in
{ name
# Script that spawns the long running processes (a foreground process). The run process is typically an execline script, but this is not mandatory
, run
# Script that gets executed when the run process terminates. This finish process is typically an execline script, but this is not mandatory
, finish ? s6-rc-setting.emptyFolder
# A list of dependencies on other s6-rc services
, notificationFd ? null
# A timeout in milliseconds. If the service is still not dead, then it is sent a SIGKILL
, timeoutKill ? null
# By default, a finish script must do its work and exit in less than 5 seconds; if it takes more than that, it is killed. This value allows you to change it.
, timeoutFinish ? null
# The maximum number of service death events that s6-supervise will keep track of (defaults to: 100, maximum: 4096)
, maxDeathTally ? null
# The signal to send to a supervised process, when it is not SIGTERM
, downSignal ? null
# Directory of data files to be included with the service configuration
, data ? null
# Directory of environment variable configuration files to be included with the service configuration
, env ? null
}:
s6-rc-setting.inFolder {
  inherit name;
  content = symlinkJoin {
    name = "s6-rc-longrun-service-${name}";
    paths = [
      (s6-rc-setting.scriptOrStringToScript {
        name = "s6-rc-run-script-for-${name}";
        scriptName = "run";
        script = run;
      })
      (s6-rc-setting.scriptOrStringToScript {
        name = "s6-rc-finish-script-for-${name}";
        scriptName = "finish";
        script = finish;
      })
      (s6-rc-setting.intProperty { value = notificationFd; name = "notification-fd"; })
      (s6-rc-setting.intProperty { value = timeoutKill; name = "timeout-kill"; })
      (s6-rc-setting.intProperty { value = timeoutFinish; name = "timeout-finish"; })
      (s6-rc-setting.intProperty { value = maxDeathTally; name = "max-death-tally"; })
      (s6-rc-setting.stringProperty { value = downSignal; name = "down-signal"; })
      (s6-rc-setting.inFolder { name = "data"; content = data; })
      (s6-rc-setting.inFolder { name = "env"; content = env; })
    ];
  };
}

