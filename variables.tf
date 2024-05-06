variable "ibmcloud_api_key" {
  description = "IBM Cloud API key."
  type        = string
  default     = ""
}

variable "region" {
  description = "IBM Cloud VPC region where resources will be deployed."
  type        = string
  default     = ""
}

variable "existing_resource_group" {
  type        = string
  description = "(Optional) The name of an existing Resource Group to use for deployed resources. If none provided, one will be created for you."
  default     = ""
}

variable "project_prefix" {
  type        = string
  description = "Identifier that will be prepended to all resource names."
  default     = ""
}

variable "allow_ssh_from" {
  type        = string
  description = "IP Address or CIDR block to allow SSH access from."
  default     = "0.0.0.0/0"
}

variable "owner" {
  type        = string
  description = "Identifier for project resources."
  default     = ""
}

variable "backend_acl_rules" {
  type = list(object({
    name        = string
    action      = string
    source      = string
    destination = string
    direction   = string
    icmp = optional(object({
      code = optional(number)
      type = optional(number)
    }))
    tcp = optional(object({
      port_min        = optional(number)
      port_max        = optional(number)
      source_port_max = optional(number)
      source_port_min = optional(number)
    }))
    udp = optional(object({
      port_min        = optional(number)
      port_max        = optional(number)
      source_port_max = optional(number)
      source_port_min = optional(number)
    }))
  }))
  description = "List of ACL rules to apply to the backend security group."
  default = [
    {
      name        = "allow-ingress-internal"
      action      = "allow"
      direction   = "inbound"
      source      = "10.0.0.0/8"
      destination = "10.0.0.0/8"
    },
    {
      name        = "allow-ingress-vse"
      action      = "allow"
      direction   = "inbound"
      source      = "161.26.0.0/16"
      destination = "10.0.0.0/8"
    },
    {
      name        = "allow-ingress-iaas"
      action      = "allow"
      direction   = "inbound"
      source      = "166.8.0.0/14"
      destination = "10.0.0.0/8"
    },
    {
      name        = "allow-egress-internal"
      action      = "allow"
      direction   = "outbound"
      source      = "10.0.0.0/8"
      destination = "10.0.0.0/8"
    },
    {
      name        = "allow-egress-vse"
      action      = "allow"
      direction   = "outbound"
      source      = "10.0.0.0/8"
      destination = "161.26.0.0/16"
    },
    {
      name        = "allow-egress-iaas"
      action      = "allow"
      direction   = "outbound"
      source      = "10.0.0.0/8"
      destination = "166.8.0.0/14"
  }]
}

variable "existing_cos_instance" {
  description = "The name of an existing COS instance to use. If not specified, a new instance will be created."
  type        = string
  default     = ""
}

variable "existing_ssh_key" {
  type        = string
  description = "The name of an existing SSH key in the VPC region that will be added to all compute instances."
  default     = ""
}

variable "classic_access" {
  description = "Allow classic access to the VPC."
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The address prefix to use for the VPC. Default is set to auto."
  type        = string
  default     = "auto"
}

variable "allow_ip_spoofing" {
  description = "Allow IP spoofing for the VPC."
  type        = bool
  default     = false
}

variable "instance_profile" {
  description = "The name of the instance profile to use for the compute instances."
  type        = string
  default     = "cx2-2x4"
}

variable "base_image" {
  description = "The name of the base image to use for the compute instances."
  type        = string
  default     = "ibm-ubuntu-22-04-1-minimal-amd64-3"
}

variable "metadata_service_enabled" {
  description = "Enable the metadata service for the VPC."
  type        = bool
  default     = true
}

variable "encryption_key" {
  description = "The encryption key to use for Consul gossip traffic."
  type        = string
}
