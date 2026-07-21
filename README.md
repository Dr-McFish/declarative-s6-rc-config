# Basic declarative configuration of s6-rc

Basic declarative configuration of s6-rc using nix. It is relativlly low level for now: all it does is translates a nix attrset with a configuration for a service(in the [s6-rc sense](https://skarnet.org/software/s6-rc/overview.html)) to the (somewhat unwieldy [s6-rc source format](https://skarnet.org/software/s6-rc/s6-rc-compile.html) in the nix store. Or directly into the compiled format using `s6-rc-compile` on the source format.

Addapted from Sander van der Burg's [nix-processmgmt](https://github.com/svanderburg/nix-processmgmt/blob/master/release.nix#L73). The origianl code was avalible under the [MIT](https://opensource.org/licenses/MIT) license.

## Usage

Assuming you are familiar with s6-rc, see [example.nix](./example.nix) for usage.
Documentation for s6-rc options: https://skarnet.org/software/s6-rc/s6-rc-compile.html
Documentation for s6 to configure deamons/longrun services: https://skarnet.org/software/s6/servicedir.html

TODO: document this better?

## Motivation

There are several project that already configure s6-rc using nix. 

1. [nix-container-images](https://github.com/cloudwatt/nix-container-images/tree/master) : unmaintained and old unfortunatly.
2. [sixos](https://codeberg.org/amjoseph/sixos/src/branch/master/mkConfiguration) 
3. Sander van der Burg's [nix-processmgmt](https://github.com/svanderburg/nix-processmgmt/blob/master/release.nix#L73), on which this repo is loosly based. It is interesting project, but because it supports many init/supervision systems at once, it is a bit complex.

These seemed a bit too complicated for my purposes, and were coupled to other functionality in their respective projects. Also I wanted to rewrite it in a more declarative and composable style. Instead of concatenating a bunch of shell commands in the build phase of mkDerivation, this repo uses writeTextFile(and friends) to declare files, and combine them with [symlinkJoin](). It remains to be seen if this is better, but on first impression the code does indeed seem simpler to me. This style does add a lot of clutter to the nix store but I don't really see how that could be a problem for now.

