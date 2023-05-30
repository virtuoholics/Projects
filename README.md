The core for applications running on EKS will be deployed first so that all prequisite services exist before Jenkins pipeline is run. Vault and RDS configs in the core, vault-ec2.tf and rds.tf, will be run in the second phase of the deployment, since connection to vault requires that vault root token be set up priorly and RDS depends on the secret that comes from vault. The vault file has been renamed to vault.tmp temporarily.

Likewise, vault config in CI/CD phase (vault-deply.tmp) will also be deployed after Jenkins pipeline deploys vault helm charts (vault pods).

Both vault-ec2.tf/tmp as well as vaul-deploy.tmp should be added to .gitignore, since they contain the secrets in plaintext.
