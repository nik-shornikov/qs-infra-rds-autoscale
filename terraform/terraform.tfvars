cluster = "ioninventory-db-instance-cluster"
alarms  = [
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "50",
    do         = "up-3"
  },
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "100",
    do         = "up-2"
  },
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "150",
    do         = "up-1"
  },
  {
    comparison = "GreaterThanOrEqualToThreshold",
    threshold  = "170",
    do         = "down-3"
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
