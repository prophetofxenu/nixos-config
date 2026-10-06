{ pkgs, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  hardware.sane.enable = true;
  users.users.xenu.extraGroups = [ "scanner" ];
  # xsane is old as hell, but I don't know of a better one
  users.users.xenu.packages = with pkgs; [ xsane ];
}
