cluster = "ioninventory-db-instance-cluster"
alarms  = [
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "110",
    do         = "up-2"
  },
  {
    comparison = "LessThanOrEqualToThreshold",
    threshold  = "140",
    do         = "up-1"
  },
  {
    comparison = "GreaterThanOrEqualToThreshold",
    threshold  = "180",
    do         = "down-2"
  },
  {
    comparison = "GreaterThanOrEqualToThreshold",
    threshold  = "210",
    do         = "down-1"
  }
]
