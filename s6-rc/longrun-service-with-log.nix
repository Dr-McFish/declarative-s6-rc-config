{lib, symlinkJoin,
 runCommand, writeTextFile }:
let
  s6-rc-setting = import ../create-s6-setting.nix {
    inherit lib symlinkJoin runCommand;
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
# Where to put the logs?
, logdir
, logUser ? "log"
, custumLogScript ? null
}:
let
  longrunService = import ./longrun-service.nix {
    inherit lib symlinkJoin runCommand writeTextFile;
  };
  logServiceName = "${name}-log";

  mainService = longrunService {
    inherit name;
    inherit flagEssential flagRecommended;
    inherit run finish dependencies notificationFd;
    inherit timeoutKill timeoutFinish;
    inherit maxDeathTally downSignal;
    inherit data env;
    inherit consumerFor pipelineName;
    producerFor = logServiceName; 
  };

  logNotificationFd = 3;

  logScript = if (custumLogScript == null) then
      # forward to 1
      # log rotations every ~day
      # keep logs for at most 2 months
      # Each file is at most 1MB
      "1 n60 R86400 s1000000 ${logdir}"
    else custumLogScript;

  # writeScript "run-${name}-log" 
  logServiceRun = ''
    #!/bin/execlineb -P
    s6-setuidgid ${logUser}:log
    s6-log -d ${toString logNotificationFd} ${logScript} ${logdir}/${name}
  '';

  logService = longrunService {
    name = logServiceName;
    run = logServiceRun;
    consumerFor = [name];
    notificationFd = logNotificationFd;
  };
in
symlinkJoin {
  name = "s6-rc-config-longrun-service-${name}+s6-log";
  paths = [
    #mainService
    logService
  ];
}

