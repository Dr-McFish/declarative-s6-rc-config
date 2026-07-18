{ lib
, runCommand
, symlinkJoin }:
rec {
  emptyFolder = runCommand "emptyFolder" {} "mkdir $out";
  
  optional-s6-config = test: consequant: if test then consequant else emptyFolder;

  booleanProperty = {value, name}:
    optional-s6-config value (
      runCommand "s6-rc-boolPropery-${name}=${toString value}" {} ''
        mkdir $out && \
        touch $out/${name}
      '');

  stringProperty = {value, name}:
    optional-s6-config (value != null) (
      runCommand "s6-rc-stringPropery-${name}=${value}" {} ''
      mkdir $out && \
      echo "${value}" > $out/${name}
    '');

  intProperty = {value, name}:
    optional-s6-config (value != null) (
      runCommand "s6-rc-intPropery-${name}=${toString value}" {} ''
      mkdir $out && \
      echo "${toString value}" > $out/${name}
    '');

  # Used for encompasing stuff in a folder
  # TODO: is copying everything instead of symlinking it better here?
  inFolder = {name, content}:
    optional-s6-config (content != null)
    (runCommand "s6-rc-${name}-folder" {} ''
      mkdir -p $out
      ln -s ${content} $out/${name}
    '');

  # serviceList in dependences.d
  namedServiceList =
  let
    serviceList = {services}: # services : [string]
      symlinkJoin {
        name = "s6-rc-serviceList";
        paths = lib.forEach (service:
          runCommand "s6-rc-seviveName-${service}" {} ''
            mkdir $out && \
            touch $out/${service}
          '') services;
      };
  in
  {services, name}:
  optional-s6-config (services != null && services != [])
    (inFolder {inherit name; content = serviceList services; });
  
  #also shotrhand
  dependencyList = {services}:
    namedServiceList {inherit services; name="dependencies.d"; };

  bundleContentList = {services}:
    namedServiceList {inherit services; name="contents.d"; };
}

