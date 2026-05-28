{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  packages = with pkgs; [
    gnumake
    poppler-utils
    pandoc
    texliveFull
  ];
}
