{stdenv, lib, symlinkJoin, runCommand, writeTextFile}:

let
  s6-rc-setting = import ../create-s6-setting.nix { inherit lib runCommand symlinkJoin writeTextFile; };
in
{ name
# When a service is flagged as essential it will not stop with the command: s6-rc -d change foo, but only: s6-rc -D change foo
, flagEssential ? false
# When importing services with the essential flag, they will automatically be put in the active rx rather than the latent one: unless the user actively makes a change before committing the set, services from the bundle will be in the default bundle and be started at boot time.
, flagRecommended ? false
# Script to run when the service is brought up (typically an execline script, but this is not mandatory)
, up
# Script to run when the service is brought down (typically an execline script, but this is not mandatory). null disables the script.
, down ? null
# A list of dependencies on other s6-rc services
, dependencies ? []
}:
s6-rc-setting.inFolder {
  inherit name;
  content = symlinkJoin {
    inherit name;
    paths = [
      (s6-rc-setting.writeNamedScript {
        text = up;
        scriptName = "up";
        name = "s6-rc-up-script-for-${name}";
      })
      (s6-rc-setting.optional-s6-config (down != null)
        (s6-rc-setting.writeNamedScript {
          text = down;
          scriptName = "down";
          name = "s6-rc-down-script-for-${name}";
        }))
      (s6-rc-setting.stringProperty { value = "oneshot"; name = "type"; })
      (s6-rc-setting.booleanProperty { value = flagEssential; name = "flag-essential"; })
      (s6-rc-setting.booleanProperty { value = flagRecommended; name = "flag-recommended"; })
      (s6-rc-setting.dependencyList { services = dependencies; })
    ];
  };
}
