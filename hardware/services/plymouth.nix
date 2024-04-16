{ config, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "breeze";
    logo = ../../files/face.png;
  };

  # replace all log output with black screen
  boot.kernelParams = [ "quiet" ];
}
