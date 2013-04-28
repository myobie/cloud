class SlaveDatabase < Database
  parse_opts :follow, :failover
end