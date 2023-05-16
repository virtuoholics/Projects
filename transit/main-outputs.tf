output "transit-vpc1-alb-dns-name" {
  value = module.transit1-vpc.transit-vpc1-alb-dns-name
}

output "transit-vpc2-alb-dns-name" {
  value = module.transit2-vpc.transit-vpc2-alb-dns-name
}

output "transit-vpc3-alb-dns-name" {
  value = module.transit3-vpc.transit-vpc3-alb-dns-name
}

/*output "receiver_accept_multi1" {
  value = module.gateway1.receiver_accept_multi1
}

output "receiver_accept_tenant1" {
  value = module.gateway1.receiver_accept_tenant1
}

output "receiver_accept_multi2" {
  value = module.gateway2.receiver_accept_multi2
}

output "receiver_accept_tenant2-1" {
  value = module.gateway2.receiver_accept_tenant2-1
}

output "receiver_accept_tenant2-2" {
  value = module.gateway2.receiver_accept_tenant2-2
}

output "receiver_accept_tenant3-1" {
  value = module.gateway3.receiver_accept_tenant3-1
}

output "receiver_accept_tenant3-2" {
  value = module.gateway3.receiver_accept_tenant3-2
}*/
