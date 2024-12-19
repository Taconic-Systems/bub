# this package definition is callable from nix-build, or flakes
# You can build them using 'nix build .#example' or (legacy) 'nix-build'
# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

{
  pkgs ? import <nixpkgs> { },
  stdenv ? pkgs.stdenv,
  lib ? pkgs.lib,
  bash ? pkgs.bash,
  age ? pkgs.age,
  openssh ? pkgs.openssh,
  gnutar ? pkgs.openssh,
  makeWrapper ? pkgs.makeWrapper,
}:
stdenv.mkDerivation {
  pname = "bub";
  version = "v0.1";

  src = ./.;

  buildInputs = [
    bash
    age
    openssh
    gnutar
  ];
  nativeBuildInputs = [
    makeWrapper
  ];
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    cp -a bub $out/bin
    cp -a bub-store $out/bin
    wrapProgram $out/bin/bub --prefix PATH : ${
      lib.makeBinPath [
        bash
        age
        openssh
        gnutar
      ]
    }
    wrapProgram $out/bin/bub-store --prefix PATH : ${
      lib.makeBinPath [
        bash
      ]
    }

  '';

}
