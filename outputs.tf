output "vpc_id" {
  value = "${aws_vpc.mod.id}"
}

output "pub_a_sub_id" {
	value = "${aws_subnet.mod-public-a.id}"
}

output "pub_b_sub_id" {
	value = "${aws_subnet.mod-public-b.id}"
}

output "pub_c_sub_id" {
	value = "${aws_subnet.mod-public-c.id}"
}

output "internal_dns_id" {
	value = "${aws_route53_zone.mod-dns.zone_id}"
}
