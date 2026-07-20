{lib, symlinkJoin, runCommand, writeTextFile}:

{ name
# List of s6-rc services that are in the bundle
, contents
# When a service is flagged as essential it will not stop with the command: s6-rc -d change foo, but only: s6-rc -D change foo
, flagEssential ? false
# When importing services with the recommended flag, they will automatically be put in the active rx rather than the latent one: unless the user actively makes a change before committing the set, services with teh recommended flag be in the default bundle and be started at boot time. 
, flagRecommended ? false
}:

let
  s6-rc-setting = import ./create-s6-rc-setting.nix {
    inherit lib symlinkJoin runCommand writeTextFile;
  };
in
s6-rc-setting.inFolder {
  inherit name;
  content = symlinkJoin {
    inherit name;
    paths = [
      (s6-rc-setting.stringProperty { name="type"; value="bundle"; })
      (s6-rc-setting.booleanProperty { name="flag-essential"; value = flagEssential; })
      (s6-rc-setting.booleanProperty { name="flag-recommended"; value = flagRecommended; })
      (s6-rc-setting.bundleContentList { services=contents; })
    ];
  };
}

