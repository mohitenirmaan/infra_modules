resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.vpc_id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = merge(
    {
      "Name" = format("%s-vpc-peering-connection", var.name)
    },
    var.tags,
  )
}