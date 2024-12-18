{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{
  boot.isContainer = true;
  networking.hostName = "bubtest";

  services.bub-server = {
    package = pkgs.bub;
    enable = true;
    users."testing" = {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKzfbkXCGcp4FU1sVyFg609XbEFbCK/Wba2XlomYlJo craig@garden"
      ];
    };
  };

  # an ssh test user
  users.users."ssh-test" = {
    isNormalUser = true;
    createHome = true;
    description = "SSH Test User";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKzfbkXCGcp4FU1sVyFg609XbEFbCK/Wba2XlomYlJo craig@garden"
    ];
  };

  system.stateVersion = "24.11";

}
