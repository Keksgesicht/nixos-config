rule = {
  matches = {
    {
      { "application.process.binary", "matches", "ferdium" },
    },
  },
  apply_properties = {
    ["node.description"] = "Ferdium",
    ["node.nick"] = "Ferdium",
    ["module-stream-restore.id"] = "sink-input-by-application-name:Ferdium",
  },
}

table.insert(stream_defaults.rules, rule)
