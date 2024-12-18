{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs; [
    pkgs.age
    pkgs.gnutar
    pkgs.openssh
    (import ./default.nix { inherit pkgs; })
  ];
}
