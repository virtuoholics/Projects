resource "aws_networkfirewall_firewall" "transit_1" {
  name                              = "transit1-nfw"
  firewall_policy_arn               = aws_networkfirewall_firewall_policy.transit_1.arn
  vpc_id                            = aws_vpc.transit_1.id
  firewall_policy_change_protection = true
  subnet_change_protection          = true

  subnet_mapping {
    subnet_id = aws_subnet.transit1_fw.id
  }

  tags = {
    Name = "transit1-nfw"
  }
}

resource "aws_networkfirewall_firewall_policy" "transit_1" {
  name = "transit1-nfw"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:pass"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.transit_1.arn
    }
  }

  tags = {
    Name = "transit1-nfw"
  }
}

resource "aws_networkfirewall_rule_group" "transit_1" {
  capacity = 100
  name     = "transit1-nfw"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          destination      = "10.4.0.0/14"
          destination_port = "8080"
          direction        = "ANY"
          protocol         = "TCP"
          source           = "10.80.8.0/24"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "IP"
          source           = "10.4.0.0/14"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:2"
        }
      }
    }
  }
}
