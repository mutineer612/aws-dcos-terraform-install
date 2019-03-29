# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default     = "install"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.1"

  # Mesosphere cluster name; do not use '.' characters
  cluster_name        = "northlogic"

  ssh_public_key_file = ""
  ssh_public_key      = ""

  # SSH key used to access ec2 instances
  aws_key_name        = "northlogic"

  admin_ips           = ["${data.http.whatismyip.body}/32"]
  #admin_ips           = ["0.0.0.0/0"]

  # Define additional tags to be applied to aws resources
  tags = {
    Owner = "mutineer612"
  }

  # Number of agent nodes
  num_masters        = "1"
  num_private_agents = "2"
  num_public_agents  = "2"

  # The CentOS ami requires subscription in AWS Marketplace.  Use the link below to subscribe.
  # https://aws.amazon.com/marketplace/pp?sku=aw0evgkw8e5c1q413zgy5pjce
  dcos_instance_os    = "centos_7.5"
  #dcos_instance_os    = "coreos_1855.5.0"

  # Defaults Bootstrap: t2.medium Master/Agent: m4.xlarge
  #bootstrap_instance_type = "t3.medium"
  #masters_instance_type = "m5.xlarge"
  #private_agents_instance_type = "m5.xlarge"
  #public_agents_instance_type = "m5.xlarge"

  # Setup additional ports to be configured in 'dcos-[cluster-name]-public-agents-lb-firewall' security group
  public_agents_additional_ports = [
    "9090"  # Access marathon-lb stats from public IP of agent node
    ]

  # Version of DC/OS
  dcos_version = "1.12.1"

  # Defines the version of DC/OS {Open Source | Enterprise Edition}, if using ee license key is required
  dcos_variant = "open"
  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("./license.txt")}"

  dcos_install_mode = "${var.dcos_install_mode}"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}
