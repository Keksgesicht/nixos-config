{ config, ... }:

{
  services.pipewire.extraConfig.pipewire =
  if (config.networking.hostName == "cookieclicker")
  then {
    "65-mic-loop" = {
      "context.modules" = [
        { name = "libpipewire-module-loopback";
          args = {
            "node.name"        = "mic_loop";
            "node.description" = "Speaker to Microphone (mic+all)";
            "audio.position"   = [ "FL" "FR" ];
            "audio.rate"       = 48000;
            "capture.props" = {
              "media.class" = "Audio/Sink";
              "node.name"   = "mic_loop_sink";
            };
            "playback.props" = {
              "node.name"   = "mic_loop_source";
              "node.target" = "void_sink";
            };
          };
        }
      ];
    };
  }
  else {};
}
