{ ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      listen = [
        { addr = "0.0.0.0"; port = 8080; }
      ];
      locations."/" = {
        proxyPass = "http://10.100.0.2:30013/";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
