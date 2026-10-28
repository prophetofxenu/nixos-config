{ pkgs, ... }:
{
  networking.wireguard.interfaces = {
    wg-pitunnel = {
      ips = [ "10.100.0.100/32" ];
      listenPort = 51820;

      privateKeyFile = "/etc/nixos/secrets/pitunnel-wireguard-privkey";

      peers = [
        {
          publicKey = "dcrgCakLYBdcmijBFpU4JD8PcT7aP82ZKYQa+VWBNmw=";
          allowedIPs = [ "10.100.0.0/24" ];
          endpoint = "c8a284f126xenu.sytes.net:51820";
          persistentKeepalive = 25;
        }
      ];

      # set DNS to the VPN server
      postSetup = ''
        ${pkgs.openresolv}/bin/resolvconf -a wg-homelan -m 0 -x <<'EOF'
          nameserver 10.100.0.1
          nameserver 208.67.222.222
          nameserver 208.67.220.220
        EOF
      '';

      postShutdown = ''
        ${pkgs.openresolv}/bin/resolvconf -d wg-homelan
      '';
    };

    wg-llp = {
      ips = [ "10.110.0.100/32" ];
      privateKeyFile = "/etc/nixos/secrets/llp-wireguard-private.key";
      peers = [
        {
          endpoint = "llp-nyc1-hb01.lepi-labs.net:51820";
          publicKey = "E3uUxMlZ9HdEg0Z+QrL145WzizKkK4Snqkqlhfayu1k=";
          allowedIPs = [ "10.110.0.0/24" ];
          persistentKeepalive = 25;
        }
      ];

      # set DNS to the VPN server
      postSetup = ''
        ${pkgs.openresolv}/bin/resolvconf -a wg-llp -m 0 -x <<'EOF'
          nameserver 10.110.0.1
          nameserver 208.67.222.222
          nameserver 208.67.220.220
        EOF
      '';

      postShutdown = ''
        ${pkgs.openresolv}/bin/resolvconf -d wg-llp
      '';
    };
  };
}
