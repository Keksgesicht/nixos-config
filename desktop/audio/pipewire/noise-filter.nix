{ config, pkgs, ... }:

let
  filter-lib = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
in
{
  services.pipewire.extraConfig.pipewire =
  if (config.networking.hostName == "cookieclicker")
  then {
    "65-noise-filter" = {
      # PipeWire:
      # - https://docs.pipewire.org/page_module_filter_chain.html
      # Plugin:
      # - https://github.com/werman/noise-suppression-for-voice
      # - https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/rnnoise-plugin/default.nix
      "context.modules" = [
        { name = "libpipewire-module-filter-chain";
          args = {
            "node.name"        = "mic_filter";
            "node.description" = "Microphone (Noise Canceling)";
            "media.name"       = "Microphone (Noise Canceling)";
            "audio.position"   = [ "MONO" ];
            "audio.rate"       = 48000;
            "filter.graph" = {
              nodes = [ {
                type    = "ladspa";
                name    = "rnnoise";
                plugin  = filter-lib;
                label   = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 95;
                  "VAD Grace Period (ms)" = 100;
                  "Retroactive VAD Grace (ms)" = 10;
                };
              } ];
            };
            "capture.props" = {
              "node.name" = "mic_filter_sink";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name"   = "mic_filter_source";
              "node.target" = "void_sink";
            };
          };
        }
        { name = "libpipewire-module-filter-chain";
          args = {
            "node.name"        = "chat_filter";
            "node.description" = "Chat (Noise Canceling)";
            "media.name"       = "Chat (Noise Canceling)";
            "audio.position"   = [ "MONO" ];
            "audio.rate"       = 48000;
            "filter.graph" = {
              nodes = [ {
                type    = "ladspa";
                name    = "rnnoise";
                plugin  = filter-lib;
                label   = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 85;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 10;
                };
              } ];
            };
            "capture.props" = {
              "media.class" = "Audio/Sink";
              "node.name"   = "chat_filter_sink";
              "node.passive" = true;
            };
            "playback.props" = {
              "media.class" = "Audio/Source";
              "node.name"   = "chat_filter_source";
              "node.target" = "void_sink";
            };
          };
        }
        { name = "libpipewire-module-filter-chain";
          args = {
            "node.name"        = "media_filter";
            "node.description" = "Media (Noise Canceling)";
            "media.name"       = "Media (Noise Canceling)";
            "audio.position"   = [ "MONO" ];
            "audio.rate"       = 48000;
            "filter.graph" = {
              nodes = [ {
                type    = "ladspa";
                name    = "rnnoise";
                plugin  = filter-lib;
                label   = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 75;
                  "VAD Grace Period (ms)" = 250;
                  "Retroactive VAD Grace (ms)" = 25;
                };
              } ];
            };
            "capture.props" = {
              "media.class" = "Audio/Sink";
              "node.name"   = "media_filter_sink";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name"   = "media_filter_source";
              "node.target" = "void_sink";
            };
          };
        }
      ];
    };
  }
  else {};
}
