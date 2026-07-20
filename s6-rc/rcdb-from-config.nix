# note that only s6-rc/bin/s6-rc-compile is needed
{stdenv, s6-rc}:

pathToConfig: 
stdenv.mkDerivation {
  name = "dbfors6-rc";
  src = pathToConfig;

  nativeBuildInputs = [s6-rc];
  buildPhase = ''
    ${s6-rc}/bin/s6-rc-compile $out .
  '';
}

