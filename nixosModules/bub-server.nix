{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.services.bub-server;
  bubUsers = lib.mapAttrs (username: userConfig: {
    isNormalUser = true;
    createHome = true;
    group = "bub";
    homeMode = "750";
    shell = "${pkgs.bub}/bin/bub-store";
    home = "${cfg.incomingDir}/${username}";
    description = "${userConfig.description}";
    openssh.authorizedKeys.keys = userConfig.keys;
    openssh.authorizedKeys.keyFiles = userConfig.keyFiles;
  }) cfg.users;

  bubMatchBlocks = lib.mapAttrs (username: userConfig: ''
    Match User ${username}
      AllowAgentForwarding no
      AllowTcpForwarding no
      PermitTTY no
      PermitTunnel no
      X11Forwarding no
  '') cfg.users;
  #        ForceCommand ${pkgs.bub}/bin/bub-store

in
{

  options = {
    services.bub-server.enable = mkEnableOption "Enable Taconic bub-store access via ssh";
    services.bub-server.package = mkOption {
      type = types.package;
      default = pkgs.bub;
    };
    services.bub-server.rootDir = mkOption {
      type = types.path;
      default = "/var/bub";
    };

    services.bub-server.incomingDir = mkOption {
      type = types.path;
      default = "${cfg.rootDir}/archives";
    };

    services.bub-server.users = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            home = lib.mkOption {
              type = types.nullOr types.path;
              default = null;
            };
            description = lib.mkOption {
              type = types.str;
              default = "Bub User";
            };
            keys = lib.mkOption {
              type = types.listOf types.singleLineStr;
              default = [ ];
              description = ''
                A list of verbatim OpenSSH public keys that will be authorized to upload to this bub server.
              '';
            };
            keyFiles = lib.mkOption {
              type = types.listOf types.path;
              default = [ ];
              description = ''A list of files each containing a single OpenSSH public key that will be authorized to upload to this bub server         '';
            };
          };
        }
      );
      description = "Define one or more user accounts that will accept bub uploads.";
      default = { };

    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length (builtins.attrNames bubUsers) >= 1;
        message = ''
          There must be at least on taconic.bub-server.users.<name> defined.
        '';
      }
    ];

    users.groups.bub = { };
    users.users = bubUsers;
    services.openssh = {
      enable = lib.mkDefault true;
      extraConfig = lib.concatStrings (builtins.attrValues bubMatchBlocks);
    };
  };
}
