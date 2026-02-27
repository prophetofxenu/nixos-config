{ lib, pkgs, ... }:

{
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.100/32" ];
      listenPort = 51820;

      privateKeyFile = "/etc/nixos/secrets/pitunnel-wireguard-privkey";

      peers = [
        {
          publicKey = "dcrgCakLYBdcmijBFpU4JD8PcT7aP82ZKYQa+VWBNmw=";
          allowedIPs = [ "10.100.0.0/24" ];
          # leaving this out for now, I don't want to commit the endpoint to GitHub
          endpoint = "";
          persistentKeepalive = 25;
        }
      ];

      # set DNS to the VPN server
      # this isn't actually working rn lol
      # postSetup = ''
      #   ${pkgs.openresolv}/bin/resolvconf -a wg0 -m 0 -x
      #   ${pkgs.openresolv}/bin/resolvconf -u
      # '';
      # postShutdown = ''
      #   ${pkgs.openresolv}/bin/resolvconf -a wg0 -x
      # '';
    };
  };
}
