cluster = "ioninventory-db-instance-cluster"
alarms  = [
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "20",
    do         = "up-2"
  },
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "30",
    do         = "up-1"
  },
  {
    comparison = "GreaterThanOrEqualToThreshold",
    threshold  = "220",
    do         = "down-2"
  },
  {
    comparison = "GreaterThanOrEqualToThreshold",
    threshold  = "270",
    do         = "down-1"
  }
]
