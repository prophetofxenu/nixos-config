{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    curl
    killall
    lm_sensors
    lsof
    pciutils
    restic
    unzip
    usbutils
    wget
    zip
  ];

  users.users.xenu.packages = if true then with pkgs; [
    kdePackages.filelight
    keepassxc
    logseq
    megasync
  ] else [];

}
