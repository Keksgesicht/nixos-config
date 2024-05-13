{ config, lib, ... }:

{
  nix.settings = {
    substituters = []
      ++ lib.optionals (config.networking.hostName != "cookieclicker") [
        "https://nix-serve.cookieclicker.keksgesicht.net/"
      ]
      ++ lib.optionals (config.networking.hostName != "cookiepi") [
        "https://nix-serve.cookiepi.keksgesicht.net/"
      ];
    trusted-public-keys = []
      ++ lib.optionals (config.networking.hostName != "cookieclicker") [
        "nix-serve.cookieclicker.keksgesicht.net:nFpvWc0EnsNT9f6DPYidYd1f3eN8CGA4RQ7u9ygDzLk="
      ]
      ++ lib.optionals (config.networking.hostName != "cookiepi") [
        "nix-serve.cookiepi.keksgesicht.net:TQ3kzk1z7Pq0aEcY7yA7E2Y6MKju/CVHBk6I/NpCF2E="
      ];
    # nixos-rebuild failed when a previously online substituters goes offline
    # this reenables local building
    fallback = true;
  };
}
