{ config, ... }:

{
  nix.settings = {
    substituters = [
      "https://nix.mirror.keksgesicht.net/"
    ];
    trusted-public-keys = [
      "nix.mirror.keksgesicht.net:aGeL8Bf8q8dqOw5IS++OBirG9KdzWG2yBw02XWWePLw="
    ];
  };
}
