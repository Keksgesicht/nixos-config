config:
{
  MY_IFLINK =
    if (config.networking.hostName == "cookieclicker") then
      "enp4s0"
    else if (config.networking.hostName == "cookiepi") then
      "enp0s31f6"
    else "eth0";
  MY_IPV6_ULU =
    if (config.networking.hostName == "cookieclicker") then
      "fd00:3581::192:168:178:150/64"
    else if (config.networking.hostName == "cookiepi") then
      "fd00:3581::192:168:178:25/64"
    else "";
  MY_IPV6_SUFFIX =
    if (config.networking.hostName == "cookieclicker") then
      "3581:150:0:1"
    else if (config.networking.hostName == "cookiepi") then
      "3581:25:0:1"
    else "";
}
