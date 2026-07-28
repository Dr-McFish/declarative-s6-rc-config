{ lib, symlinkJoin, runCommand
, writeTextFile }:
let
  s6-rc-setting = import ../create-s6-setting.nix {
    inherit lib runCommand symlinkJoin writeTextFile;
  };
in
{ name
# When a service is flagged as essential it will not stop with the command: s6-rc -d change foo, but only: s6-rc -D change foo
, flagEssential ? false
# When importing services with the recommended flag, they will automatically be put in the active rx rather than the latent one: unless the user actively makes a change before committing the set, services with teh recommended flag be in the default bundle and be started at boot time.
, flagRecommended ? false
# Script that spawns the long running processes (a foreground process). The run process is typically an execline script, but this is not mandatory
, run
# Script that gets executed when the run process terminates. This finish process is typically an execline script, but this is not mandatory
, finish ? s6-rc-setting.emptyFolder
# A list of dependencies on other s6-rc services
, dependencies ? []
# Number of the file descriptor that the service can use to send a readiness notification message to. null disables readiness notification
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
# Longrun service for which this service produces data. The corresponding service must also declare this service as a consumer. null specifies that this service is not a producer.
, producerFor ? null
# List of longrun services that this service should consume data from. The corresponding services must also declare this service as a producer.
, consumerFor ? []
# If this file exists along with a consumer-for file, and there is no producer-for file, then a bundle will automatically be created,
# named with the content of the pipeline-name file, and containing all the services in the pipeline that ends at service.
# The pipeline-name file is ignored if service is not a last consumer.
, pipelineName ? null
# TODO Specifies which groups and users that need to be created.
, credentials ? {}
}:
let
  # Somewhat annoyingly, consumer-for is not a folder with the names of the files being
  # the services, but a text file with a service name per line.
  consumerForFile = s6-rc-setting.optional-s6-config (consumerFor != []) (
    s6-rc-setting.stringProperty {
      name = "consumer-for";
      value = lib.strings.join "\n" consumerFor;
    });
in
s6-rc-setting.inFolder {
  inherit name;
  content = symlinkJoin {
    name = "s6-rc-longrun-service-${name}";
    paths = [
      (s6-rc-setting.stringProperty { value = "longrun"; name = "type"; })
      (s6-rc-setting.booleanProperty { value = flagEssential; name = "flag-essential"; })
      (s6-rc-setting.booleanProperty { value = flagRecommended; name = "flag-recommended"; })
      (s6-rc-setting.writeNamedScript {
        name = "s6-rc-run-script-for-${name}";
        scriptName = "run";
        text = run;
      })
      (s6-rc-setting.writeNamedScript {
        name = "s6-rc-finish-script-for-${name}";
        scriptName = "finish";
        text = finish;
      })
      (s6-rc-setting.dependencyList { services = dependencies; })
      (s6-rc-setting.intProperty { value = notificationFd; name = "notification-fd"; })
      (s6-rc-setting.intProperty { value = timeoutKill; name = "timeout-kill"; })
      (s6-rc-setting.intProperty { value = timeoutFinish; name = "timeout-finish"; })
      (s6-rc-setting.intProperty { value = maxDeathTally; name = "max-death-tally"; })
      (s6-rc-setting.stringProperty { value = downSignal; name = "down-signal"; })
      (s6-rc-setting.inFolder { name = "data"; content = data; })
      (s6-rc-setting.inFolder { name = "env"; content = env; })
      (s6-rc-setting.stringProperty { value = producerFor; name = "producer-for"; })
      consumerForFile
      (s6-rc-setting.stringProperty { value = pipelineName; name = "pipeline-name"; })
    ];
  };
}

