{ pkgs, ... }:
{
  networking.wireguard.interfaces = {
    wg-llp = {
      ips = [ "10.110.0.101/32" ];
      privateKeyFile = "/etc/nixos/secrets/wireguard-llp.key";
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
        ${pkgs.openresolv}/bin/resolvconf -a wg-llp -m 0 <<'EOF'
          nameserver 10.110.0.1
        EOF
      '';

      postShutdown = ''
        ${pkgs.openresolv}/bin/resolvconf -d wg-llp
      '';
    };
  };
}
