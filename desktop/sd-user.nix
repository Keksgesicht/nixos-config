{ ... }:

{
  systemd.services = {
    /*
     * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogFilterPatterns=
     * https://forum.manjaro.org/t/stable-update-2023-06-04-kernels-gnome-44-1-plasma-5-27-5-python-3-11-toolchain-firefox/141610/3
     * do not log messages with the following regex
     */
    "user@" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        TimeoutStopSec = 23;
        LogFilterPatterns = [
          ''~kwin_scene_opengl: 0x[0-9]: GL_INVALID_OPERATION in glDrawBuffers\(unsupported buffer GL_BACK_LEFT\)''
          # Brave
          "~handshake failed; returned -1, SSL error code 1, net_error -100"
          "~Cannot create bo with format= YUV_420_BIPLANAR and usage=SCANOUT_CPU_READ_WRITE"
          ''~ERROR:gpu_channel.cc\(502\)\] Buffer Handle is null.''
          ''~ERROR:shared_image_interface_proxy.cc\(129\)\] Buffer handle is null\. Not creating a mailbox from it\.''
          # Gaming
          ''~wine: using kernel write watches, use_kernel_writewatch 1\.''
          ''~ERROR: ld\.so: object 'libgamemodeauto\.so\.0' from LD_PRELOAD cannot be preloaded \(cannot open shared object file\): ignored\.''
        ];
      };
    };

    # faster shutdowns
    "display-manager" = {
      serviceConfig = {
        TimeoutStopSec = 23;
      };
    };
  };
}
