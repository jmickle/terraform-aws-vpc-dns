# Create the VPC Object
resource "aws_vpc" "mod" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "${var.name}"
  }
}

# Create the Public subnets 1 for each AZ
resource "aws_subnet" "mod-public-a" {
    vpc_id = "${aws_vpc.mod.id}"
    cidr_block = "${var.public_subnet_cidr_a}"
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.name}-Public-A"
    }
}

resource "aws_subnet" "mod-public-b" {
    vpc_id = "${aws_vpc.mod.id}"
    cidr_block = "${var.public_subnet_cidr_b}"
    availability_zone = "${var.region}b"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.name}-Public-B"
    }
}

resource "aws_subnet" "mod-public-c" {
    vpc_id = "${aws_vpc.mod.id}"
    cidr_block = "${var.public_subnet_cidr_c}"
    availability_zone = "${var.region}c"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.name}-Public-C"
    }
}

# Create an IGW

resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"
}

# Create the NAT Gateways - this is for instances in each AZ without EIP
# We are create a nat gateway per AZ for true AZ isolation
resource "aws_nat_gateway" "mod-gw-a" {
    allocation_id = "${var.public_nat_gw_ipalloc_a}"
    subnet_id = "${aws_subnet.mod-public-a.id}"
}

resource "aws_nat_gateway" "mod-gw-b" {
    allocation_id = "${var.public_nat_gw_ipalloc_b}"
    subnet_id = "${aws_subnet.mod-public-b.id}"
}

resource "aws_nat_gateway" "mod-gw-c" {
    allocation_id = "${var.public_nat_gw_ipalloc_c}"
    subnet_id = "${aws_subnet.mod-public-c.id}"
}

# Create public route table for instances with EIP's
resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.mod.id}"

  tags {
    Name = "${var.name}-public"
  }
}

# Add route for non local subnets to flow through IGW
resource "aws_route" "public-internet-gateway-route" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
}

# Associate Public Subnets with IGW Route
resource "aws_route_table_association" "igw-public-a" {
    subnet_id = "${aws_subnet.mod-public-a.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "igw-public-b" {
    subnet_id = "${aws_subnet.mod-public-b.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "igw-public-c" {
    subnet_id = "${aws_subnet.mod-public-c.id}"
    route_table_id = "${aws_route_table.public.id}"
}


# Now we start the private networks

# Create the private route table
resource "aws_route_table" "private-table-a" {
  vpc_id           = "${aws_vpc.mod.id}"

  tags {
    Name = "${var.name}-private-a"
  }
}

resource "aws_route_table" "private-table-b" {
  vpc_id           = "${aws_vpc.mod.id}"

  tags {
    Name = "${var.name}-private-b"
  }
}

resource "aws_route_table" "private-table-c" {
  vpc_id           = "${aws_vpc.mod.id}"

  tags {
    Name = "${var.name}-private-c"
  }
}

# Add some private routes to each respective NGW 
# This gives us AZ Isolation

resource "aws_route" "private-igw-a-route" {
  route_table_id         = "${aws_route_table.private-table-a.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = "${aws_nat_gateway.mod-gw-a.id}"
}

resource "aws_route" "private-igw-b-route" {
  route_table_id         = "${aws_route_table.private-table-b.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = "${aws_nat_gateway.mod-gw-b.id}"
}

resource "aws_route" "private-igw-c-route" {
  route_table_id         = "${aws_route_table.private-table-c.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = "${aws_nat_gateway.mod-gw-c.id}"
}

# Lets create an admin subnet and bind it to a table
# note each vertical will create its own subnets in its files thus binding there
resource "aws_subnet" "admin-private-subnet" {
    vpc_id = "${aws_vpc.mod.id}"
    cidr_block = "${var.admin_subnet_cidr}"
    availability_zone = "${var.region}a"

    tags {
        Name = "${var.name}-private-admin"
    }
}

resource "aws_route_table_association" "igw-private-a" {
    subnet_id = "${aws_subnet.admin-private-subnet.id}"
    route_table_id = "${aws_route_table.private-table-a.id}"
}

# Create internal DNS Zone

resource "aws_route53_zone" "mod-dns" {
   name = "${var.internal_dns_zone}"

   vpc_id = "${aws_vpc.mod.id}"

   tags {
    Environment = "${var.environment}"
  }
}

# set up DHCP options to allocate local dns zone for resolver
resource "aws_vpc_dhcp_options" "mod-dns_resolver" {
    domain_name = "${var.internal_dns_zone}"
    domain_name_servers = ["AmazonProvidedDNS"]

    tags {
      Name = "${var.name}-DNS-DHCP"
    }
}

# Bind the new dhcp options set

resource "aws_vpc_dhcp_options_association" "mod-dhcp-bind" {
    vpc_id = "${aws_vpc.mod.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.mod-dns_resolver.id}"
}
