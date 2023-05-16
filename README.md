This multi-account/multi-region Transit-Gateway project demonstrates how several VPCs in three regions could be connected together with the help of a Transit-Gateway in each region, with fully meshed peerings.

The routing tables provide a perfect example of how traffic entering a VPC in one-region through an Application Load-Balancer passes through different routing stages and reaches the destinations behind a Network Load-Balancer in a VPC in another region.

AWS Network Firewalls are used for advanced traffic inspection, monitoring and policing.

The entire project is built with Terraform.
