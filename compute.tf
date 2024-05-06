resource "ibm_is_instance" "bastion" {
  name           = "${local.prefix}-bastion"
  vpc            = ibm_is_vpc.vpc.id
  image          = data.ibm_is_image.base.id
  profile        = var.instance_profile
  resource_group = module.resource_group.resource_group_id
  metadata_service {
    enabled            = true
    protocol           = "https"
    response_hop_limit = 5
  }

  boot_volume {
    auto_delete_volume = true
    name               = "${local.prefix}-bastion-boot-volume"
  }

  primary_network_attachment {
    name = "${local.prefix}-primary-att"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.bastion_vnic.id
    }
  }

  zone = local.vpc_zones[0].zone
  keys = local.ssh_key_ids
  tags = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_floating_ip" "bastion" {
  name           = "${local.prefix}-bastion-public-ip"
  resource_group = module.resource_group.resource_group_id
  zone           = local.vpc_zones[0].zone
  tags           = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_virtual_network_interface" "bastion_vnic" {
  allow_ip_spoofing         = true
  auto_delete               = false
  enable_infrastructure_nat = true
  name                      = "${local.prefix}-bastion-vnic"
  subnet                    = ibm_is_subnet.frontend_subnets.0.id
  resource_group            = module.resource_group.resource_group_id
  security_groups           = [module.bastion_security_group.security_group_id]
  tags                      = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_virtual_network_interface_floating_ip" "vni_fip" {
  virtual_network_interface = ibm_is_virtual_network_interface.bastion_vnic.id
  floating_ip               = ibm_is_floating_ip.bastion.id
}

resource "ibm_is_virtual_network_interface" "hashistack_vnic" {
  count                     = 5
  allow_ip_spoofing         = true
  auto_delete               = false
  enable_infrastructure_nat = true
  name                      = "${local.prefix}-hashi-${count.index + 1}-vnic"
  subnet                    = ibm_is_subnet.backend_subnets[count.index % 3].id
  resource_group            = module.resource_group.resource_group_id
  security_groups           = [module.hashistack_security_group.security_group_id]
  tags                      = concat(local.tags, ["zone:${local.vpc_zones[count.index % 3].zone}"])
}

resource "ibm_is_instance" "hashistack_compute" {
  count          = 5
  name           = "${local.prefix}-hashi-${count.index + 1}"
  vpc            = ibm_is_vpc.vpc.id
  image          = data.ibm_is_image.base.id
  profile        = var.instance_profile
  resource_group = module.resource_group.resource_group_id
  metadata_service {
    enabled            = true
    protocol           = "https"
    response_hop_limit = 5
  }

  boot_volume {
    auto_delete_volume = true
    name               = "${local.prefix}-hashiboot-${count.index + 1}"
  }

  primary_network_attachment {
    name = "${local.prefix}-hashi-${count.index + 1}-vnic-att"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.hashistack_vnic[count.index].id
    }
  }

  zone = local.vpc_zones[count.index % 3].zone
  keys = local.ssh_key_ids
  tags = local.tags
}
