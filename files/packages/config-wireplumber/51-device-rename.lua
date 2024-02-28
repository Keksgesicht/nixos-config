rule = {
  matches = {
    {
      { "node.name", "equals", "alsa_output.pci-0000_0a_00.3.analog-surround-40" },
    },
  },
  apply_properties = {
    ["node.description"] = "Mainboard Speaker",
    ["node.nick"] = "Mainboard Speaker",
  },
}

table.insert(alsa_monitor.rules, rule)
