# TODO give this module options
{ lib, pkgs, ... }:

{
  # use wg for creating keypairs
  environment.systemPackages = [ pkgs.wireguard-tools ];

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "wg0";
  networking.nat.internalInterfaces = [ "enu1u1" ];

  networking.firewall = {
    allowedUDPPorts = [ 53 51820 ];
    trustedInterfaces = [ "wg0" ];
  };

  # DNS server for resolving forwarded hostnames
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;

    settings = {
      # route normal queries to the router
      server = [ "192.168.1.1" ];

      address = [
        "/xenu-pitunnel/10.100.0.1"
        "/eve.lan/10.100.0.2"
        "/xenu-q58/10.100.0.3"
      ];
    };
  };

  networking.wireguard.interfaces = {
    wg0 = {
      # IP address and subnet of server's end of tunnel
      ips = [ "10.100.0.1/32" ];
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.1/24 -o enu1u1 -j MASQUERADE

        # create forwarding rules for DNS entries
        # TODO read directly from services.dnsmasq.address or something similar
        ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i wg0 -d 10.100.0.2 -j DNAT --to-destination 192.168.1.2
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enu1u1 -d 192.168.1.2 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i wg0 -d 10.100.0.3 -j DNAT --to-destination 192.168.1.3
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enu1u1 -d 192.168.1.3 -j MASQUERADE
      '';

      # Undo the above
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.1/24 -o enu1u1 -j MASQUERADE

        ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i wg0 -d 10.100.0.2 -j DNAT --to-destination 192.168.1.2
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enu1u1 -d 192.168.1.2 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i wg0 -d 10.100.0.3 -j DNAT --to-destination 192.168.1.3
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enu1u1 -d 192.168.1.3 -j MASQUERADE
      '';

      # this will get copied to the global store so isn't great security wise but agenix
      # was a pain in the ass so I don't care
      privateKeyFile = "/etc/nixos/secrets/wireguard-server-keys/private";

      # allowed peers
      peers = [
        {
          name = "xenu-t14";
          publicKey = "jAydWJqEZ4doNNJk139q7XBZ7O1LHjQD3FpFfem7ZXU=";
          allowedIPs = [ "10.100.0.100/32" ];
        }
        {
          name = "xenu-phone";
          publicKey = "LwCFEhfcRybCmvlb9jxw0xKjvdH3YQ94/SOPZxPwKVY=";
          allowedIPs = [ "10.100.0.110/32" ];
        }
      ];
    };
  };
}
