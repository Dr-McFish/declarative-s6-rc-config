{lib, symlinkJoin, runCommand}:

{ name
# When a service is flagged as essential it will not stop with the command: s6-rc -d change foo, but only: s6-rc -D change foo
, flagEssential ? false
# When importing services with the recommended flag, they will automatically be put in the active rx rather than the latent one: unless the user actively makes a change before committing the set, services with teh recommended flag be in the default bundle and be started at boot time. 
, flagRecommended ? false
# List of s6-rc services that are in the bundle
, contents ? []
# Arbitrary commands executed after generating the configuration files
, postInstall ? ""
}:

let
  util = import ./util.nix {
    inherit lib symlinkJoin runCommand;
  };
in
symlinkJoin {
  inherit name;
  paths = [util.indirectionWrapper {inherit name; content = [
    (util.stringProperty { name="type"; value="bundle"; })
    (util.booleanProperty { name="flag-essential"; value = flagEssential; })
    (util.booleanProperty { name="flag-recommended"; value = flagEssential; })
    (util.bundleContentList { services=contents; })
  ];}];
}

