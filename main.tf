# If no project prefix is defined, generate a random one 
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  numeric = false
  upper   = false
}

# If an existing resource group is provided, this module returns the ID, otherwise it creates a new one and returns the ID
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

resource "tls_private_key" "ssh" {
  count     = var.existing_ssh_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "ssh_key" {
  count             = var.existing_ssh_key != "" ? 0 : 1
  source            = "terraform-ibm-modules/vpc/ibm//modules/ssh-key"
  name              = "${local.prefix}-${var.region}-sshkey"
  resource_group_id = module.resource_group.resource_group_id
  public_key        = tls_private_key.ssh.0.public_key_openssh
  tags              = local.tags
}

resource "ibm_is_vpc" "vpc" {
  name                        = "${local.prefix}-vpc"
  resource_group              = module.resource_group.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management   = var.default_address_prefix
  default_network_acl_name    = "${local.prefix}-vpc-default-nacl"
  default_security_group_name = "${local.prefix}-vpc-default-sg"
  default_routing_table_name  = "${local.prefix}-vpc-default-rt"
  tags                        = local.tags
}

resource "ibm_is_public_gateway" "pgws" {
  count          = length(data.ibm_is_zones.regional.zones)
  name           = "${local.prefix}-zone-${count.index + 1}-pgw"
  resource_group = module.resource_group.resource_group_id
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.vpc_zones[count.index].zone
  tags           = concat(local.tags, ["zone:${local.vpc_zones[count.index].zone}"])
}

resource "ibm_is_subnet" "frontend_subnets" {
  count                    = length(data.ibm_is_zones.regional.zones)
  name                     = "${local.prefix}-zone-${count.index + 1}-frontend-subnet"
  resource_group           = module.resource_group.resource_group_id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[count.index].zone
  tags                     = concat(local.tags, ["networktier:frontend", "zone:${local.vpc_zones[count.index].zone}"])
  total_ipv4_address_count = "128"
  public_gateway           = ibm_is_public_gateway.pgws[count.index].id
}

resource "ibm_is_subnet" "backend_subnets" {
  count                    = length(data.ibm_is_zones.regional.zones)
  name                     = "${local.prefix}-zone-${count.index + 1}-backend-subnet"
  resource_group           = module.resource_group.resource_group_id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[count.index].zone
  tags                     = concat(local.tags, ["networktier:backend", "zone:${local.vpc_zones[count.index].zone}"])
  total_ipv4_address_count = "256"
  public_gateway           = ibm_is_public_gateway.pgws[count.index].id
}