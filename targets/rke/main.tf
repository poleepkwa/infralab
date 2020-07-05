resource "openstack_compute_secgroup_v2" "rke" {
  name        = "rke"
  description = "rke"

  rule {
    from_port   = 2376
    to_port     = 2376
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2379
    to_port     = 2379
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2380
    to_port     = 2380
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 9099
    to_port     = 9099
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 10254
    to_port     = 10254
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}





resource "openstack_networking_network_v2" "rke" {
  name           = "rke"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "rke" {
  name       = "rke"
  network_id = openstack_networking_network_v2.rke.id
  cidr       = "10.164.0.0/24"
  ip_version = 4
}





data "openstack_networking_network_v2" "external" {
  name = "external"
}

resource "openstack_networking_router_v2" "rke" {
  name                = "rke-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "rke" {
  router_id = openstack_networking_router_v2.rke.id
  subnet_id = openstack_networking_subnet_v2.rke.id
}





# etcd nodes
resource "openstack_compute_instance_v2" "etcd1" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "etcd1"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.11"
  }
}

resource "openstack_networking_floatingip_v2" "etcd1_ip" {
  pool = "external"
  address = "10.20.20.11"
}

resource "openstack_compute_floatingip_associate_v2" "etcd1_ip" {
  floating_ip = openstack_networking_floatingip_v2.etcd1_ip.address
  instance_id = openstack_compute_instance_v2.etcd1.id
  fixed_ip    = openstack_compute_instance_v2.etcd1.network.0.fixed_ip_v4
}

resource "openstack_compute_instance_v2" "etcd2" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "etcd2"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.12"
  }
}

resource "openstack_networking_floatingip_v2" "etcd2_ip" {
  pool = "external"
  address = "10.20.20.12"
}

resource "openstack_compute_floatingip_associate_v2" "etcd2_ip" {
  floating_ip = openstack_networking_floatingip_v2.etcd2_ip.address
  instance_id = openstack_compute_instance_v2.etcd2.id
  fixed_ip    = openstack_compute_instance_v2.etcd2.network.0.fixed_ip_v4
}

resource "openstack_compute_instance_v2" "etcd3" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "etcd3"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.13"
  }
}

resource "openstack_networking_floatingip_v2" "etcd3_ip" {
  pool = "external"
  address = "10.20.20.13"
}

resource "openstack_compute_floatingip_associate_v2" "etcd3_ip" {
  floating_ip = openstack_networking_floatingip_v2.etcd3_ip.address
  instance_id = openstack_compute_instance_v2.etcd3.id
  fixed_ip    = openstack_compute_instance_v2.etcd3.network.0.fixed_ip_v4
}




# control nodes
resource "openstack_compute_instance_v2" "control1" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "control1"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.21"
  }
}

resource "openstack_networking_floatingip_v2" "control1_ip" {
  pool = "external"
  address = "10.20.20.21"
}

resource "openstack_compute_floatingip_associate_v2" "control1_ip" {
  floating_ip = openstack_networking_floatingip_v2.control1_ip.address
  instance_id = openstack_compute_instance_v2.control1.id
  fixed_ip    = openstack_compute_instance_v2.control1.network.0.fixed_ip_v4
}

resource "openstack_compute_instance_v2" "control2" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "control2"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.22"
  }
}

resource "openstack_networking_floatingip_v2" "control2_ip" {
  pool = "external"
  address = "10.20.20.22"
}

resource "openstack_compute_floatingip_associate_v2" "control2_ip" {
  floating_ip = openstack_networking_floatingip_v2.control2_ip.address
  instance_id = openstack_compute_instance_v2.control2.id
  fixed_ip    = openstack_compute_instance_v2.control2.network.0.fixed_ip_v4
}





# worker nodes
resource "openstack_compute_instance_v2" "worker1" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "worker1"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.31"
  }
}

resource "openstack_networking_floatingip_v2" "worker1_ip" {
  pool = "external"
  address = "10.20.20.31"
}

resource "openstack_compute_floatingip_associate_v2" "worker1_ip" {
  floating_ip = openstack_networking_floatingip_v2.worker1_ip.address
  instance_id = openstack_compute_instance_v2.worker1.id
  fixed_ip    = openstack_compute_instance_v2.worker1.network.0.fixed_ip_v4
}


resource "openstack_compute_instance_v2" "worker2" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "worker2"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.32"
  }
}

resource "openstack_networking_floatingip_v2" "worker2_ip" {
  pool = "external"
  address = "10.20.20.32"
}

resource "openstack_compute_floatingip_associate_v2" "worker2_ip" {
  floating_ip = openstack_networking_floatingip_v2.worker2_ip.address
  instance_id = openstack_compute_instance_v2.worker2.id
  fixed_ip    = openstack_compute_instance_v2.worker2.network.0.fixed_ip_v4
}


resource "openstack_compute_instance_v2" "worker3" {
  depends_on = [ openstack_networking_subnet_v2.rke ]

  name            = "worker3"
  image_name      = "centos7"
  flavor_name     = "m1.mini"
  key_pair        = "microstack"

  security_groups = [
    "default",
    openstack_compute_secgroup_v2.rke.name
  ]

  network {
    name = "rke"
    fixed_ip_v4 = "10.164.0.33"
  }
}

resource "openstack_networking_floatingip_v2" "worker3_ip" {
  pool = "external"
  address = "10.20.20.33"
}

resource "openstack_compute_floatingip_associate_v2" "worker3_ip" {
  floating_ip = openstack_networking_floatingip_v2.worker3_ip.address
  instance_id = openstack_compute_instance_v2.worker3.id
  fixed_ip    = openstack_compute_instance_v2.worker3.network.0.fixed_ip_v4
}

