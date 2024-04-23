{ ... }:

{
  nix.settings = {
    substituters = [
      "https://nix-serve.cookieclicker.keksgesicht.net/"
    ];
    trusted-public-keys = [
      "nix-serve.cookieclicker.keksgesicht.net:nFpvWc0EnsNT9f6DPYidYd1f3eN8CGA4RQ7u9ygDzLk="
    ];
  };
}
