{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      logseq = prev.logseq.override {
        electron_39 = prev.electron_41;
      };
    })
  ];
}
