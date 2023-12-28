{ config, pkgs, ... }:

{
  environment.etc = {
    "htoprc" = {
      source = ../../files/linux-root/etc/htoprc;
    };
  };

  environment.systemPackages = [
    pkgs.htop
  ];

  programs.htop = {
    #enable = true;

    # header_layout has to be before column_*
    # but nixpkgs generates everything alphabeticly
    settings = {
      /*
      header_margin = false;
      header_layout = "two_50_50";

      column_meters_0 = [ "LeftCPUs2" "Blank" "CPU" "Memory" "Swap" ];
      column_meter_modes_0 = [ 1 2 1 1 1 ];
      column_meters_1 = [ "RightCPUs2" "Blank" "Tasks" "LoadAverage" "Uptime" ];
      column_meter_modes_1 = [ 1 2 2 2 2 ];
      fields = [ 0 3 48 17 18 46 47 118 39 119 2 20 49 1 ];

      hide_function_bar = false;
      hide_kernel_threads = true;
      hide_running_in_container = false;
      hide_userland_threads = true;

      highlight_base_name = true;
      highlight_changes = false;
      highlight_changes_delay_secs = 5;
      highlight_deleted_exe = true;
      highlight_megabytes = true;
      highlight_threads = true;

      shadow_distribution_path_prefix = false;
      shadow_other_users = false;

      show_cpu_usage = true;
      show_cpu_frequency = true;
      show_cpu_temperature = true;
      show_merged_command = false;
      show_program_path = true;
      show_thread_names = false;

      tree_sort_key = true;
      tree_sort_direction = true;
      tree_view = false;
      tree_view_always_by_pid = true;

      account_guest_in_cpu_meter = false;
      all_branches_collapsed = false;
      color_scheme = false;
      cpu_count_from_one = false;
      detailed_cpu_time = false;
      degree_fahrenheit = false;
      enable_mouse = true;
      find_comm_in_cmdline = true;
      screen_tabs = false;
      strip_exe_from_cmdline = true;
      update_process_names = false;

      delay = 5;
      sort_key = 46;
      sort_direction = -1;
      */
    };
  };
}
