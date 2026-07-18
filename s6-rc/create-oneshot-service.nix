{stdenv, lib, symlinkJoin}:

let
  util = import ./util.nix { inherit lib; };
in
{ name
# When a service is flagged as essential it will not stop with the command: s6-rc -d change foo, but only: s6-rc -D change foo
, flagEssential ? false
# When importing services with the essential flag, they will automatically be put in the active rx rather than the latent one: unless the user actively makes a change before committing the set, services from the bundle will be in the default bundle and be started at boot time.
, flagRecommended ? false
# Script to run when the service is brought up (typically an execline script, but this is not mandatory)
, up
# Script to run when the service is brought down (typically an execline script, but this is not mandatory). null disables the script.
, down ? util.emptyFolder
# A list of dependencies on other s6-rc services
, dependencies ? []
}:
symlinkJoin {
  inherit name;
  paths = [
    up
    down
    util.stringProperty { value = "oneshot"; filename = "type"; }
    util.booleanProperty { value = flagEssential; filename = "flag-essential"; }
    util.booleanProperty { value = flagRecommended; filename = "flag-recommended"; }
    util.dependencyList { services = dependencies; }
  ];
  
}
