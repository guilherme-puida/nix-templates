{
  description = "Collection of personal nix flake templates";

  outputs = { self }: {
    templates = rec {
      go = {
        path = ./go;
        description = "Go template using gomod2nix";
      };
    };
  };
}
