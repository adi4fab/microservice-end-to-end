# Global resources (IAM, Organizations, Identity Center) have no region of
# their own, but the API call still needs an endpoint. Everything global
# talks to us-east-1.
locals {
  aws_region   = "us-east-1"
  region_short = "use1"
}
