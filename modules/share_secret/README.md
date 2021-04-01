## How to use this module

```hcl
module "share_zone_id" {
 source = "git::https://github.com/hmrc/public-artefact-store.git//modules/share_secret?ref=v14.1.0"

 secret_name  = "/example-name"

 secret_value = module.cloudfront_cdn.hosted_zone_id

 allowed_account_ids = [
   327423472347234,
   248588593459044
 ]

 tags = {
   my-example-tag = "yes"
 }
}
```

## Retrive a secret from this module
```hcl
data "aws_secretsmanager_secret_version" "lab03_artefacts_domain_name" {
 secret_id = "arn:aws:secretsmanager:eu-west-2:${local.bnd_account_id}:secret:/example-var"
}
```

