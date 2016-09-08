# terraform-aws-vpc-dns

## Usage:
```module "new-vpc" {
	    source = "github.com/jmickle/terraform-aws-vpc-dns"
	    name = "new-vpc"
	    cidr = "100.1.0.0/16"
	    public_subnet_cidr_a = "100.1.100.0/24"
	    public_subnet_cidr_b = "100.1.101.0/24"
	    public_subnet_cidr_c = "100.1.102.0/24"
	    admin_subnet_cidr = "100.1.15.0/24"
	    public_nat_gw_ipalloc_a = "eipalloc-1234567"
	    public_nat_gw_ipalloc_b = "eipalloc-7654321"
	    public_nat_gw_ipalloc_c = "eipalloc-9876543"
	    region = "us-west-2"
	    environment = "production"
	    internal_dns_zone = "new-vpc.local"

    }```