module "hashistack_security_group" {
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.5.0"
  add_ibm_cloud_internal_rules = true
  vpc_id                       = ibm_is_vpc.vpc.id
  resource_group               = module.resource_group.resource_group_id
  security_group_name          = "${local.prefix}-hashistack-sg"
  security_group_rules = [
    {
      name      = "inbound-consul-dns-udp"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      udp = {
        port_min = 8600
        port_max = 8600
      }
    },
    {
      name      = "inbound-consul-dns-tcp"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 8600
        port_max = 8600
      }
    },
    {
      name      = "inbound-consul-http"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 8500
        port_max = 8500
      }
    },
    {
      name      = "inbound-consul-wan-lan-udp"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      udp = {
        port_min = 8301
        port_max = 8302
      }
    },
    {
      name      = "inbound-consul-lan-wan-tcp"
      direction = "inbound"
      remote    = "0.0.0.0/0"

      tcp = {
        port_min = 8300
        port_max = 8302
      }
    },
    {
      name      = "inbound-ssh"
      direction = "inbound"
      remote    = module.bastion_security_group.security_group_id
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "allow-http-outbound-all"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name      = "allow-https-outbound-all"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    }
  ]
}


module "bastion_security_group" {
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.5.0"
  add_ibm_cloud_internal_rules = true
  vpc_id                       = ibm_is_vpc.vpc.id
  resource_group               = module.resource_group.resource_group_id
  security_group_name          = "${local.prefix}-bastion-sg"
  security_group_rules = [
    {
      name      = "allow-ssh-from-inbound"
      direction = "inbound"
      remote    = var.allow_ssh_from
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "allow-ssh-outbound-all"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "allow-http-outbound-all"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name      = "allow-https-outbound-all"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    }
  ]
}