It's a simple Linux/Ansible IaC project that creates an EC2 instance and installs/configures some applications on it through Ansible.

The purpose of this project is to demonstrate how Ansible replaces EC2 instance user-data that by default runs only when the instance first boots up.

This is achieved with the help of Terraform "null_resource" resource, that connects to the instance with a remote-exec provisioner and runs an Ansible playbook on it through a local-exec provisioner.
