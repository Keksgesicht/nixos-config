{ config, pkgs, ...}:

{
  imports = [
    # https://search.nixos.org/options?channel=23.05&query=virtualisation.podman
    ../../system/container.nix
    # containers
    ./dyndns.nix
    ./lancache.nix
    ./nextcloud.nix
    ./pihole.nix
    ./proxy.nix
    ./unbound.nix
  ];

  environment.systemPackages = with pkgs; [
    skopeo
  ];

  /*
   * https://github.com/containers/podman/issues/17609
   * podman pull docker.io/pihole/pihole:latest
   * podman inspect docker.io/pihole/pihole:latest | jq '.[]["Digest"]'
   * skopeo inspect docker://docker.io/alpinelinux/unbound:latest | jq '.Digest'
   *
   * https://nixos.wiki/wiki/Docker#How_to_calculate_the_sha256_of_a_pulled_image
   * skopeo copy docker://alpinelinux/unbound docker-archive:///tmp/image.tgz:alpinelinux/unbound:latest
   * nix-hash --base32 --flat --type sha256 /tmp/image.tgz
   */
}
