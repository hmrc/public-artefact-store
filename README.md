
# public-artefact-store

### Purpose
This project was created as a simple way to serve public artefacts on AWS after [our previous solution was sunset](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/).

Some configuration may be specific to our use-case, however the bulk of this Terraform is likely to be of use to others that want an easy way to serve static files on AWS

## Design
```
         ┌─────────────────┐
         │     Route 53    │ DNS
         └────────┬────────┘
                  │
         ┌────────▼────────┐
    ┌───►│   Cloudfront    │  CDN
    │    └────────┬────────┘
    │             │
    │    ┌────────▼────────┐ This lambda rewrites requests
    │    │     Lambda      │ that end with / to /index.html
    │    └────────┬────────┘
    │             │
    │    ┌────────▼────────┐
    │    │       S3        │ Private bucket origin for files
    │    └─────────────────┘
    │
    │             ┌────────┐
    └─────────────┤  WAFV2 │ Filters undesirable CDN traffic
                  └────┬───┘
                       │
                  ┌────▼───┐
                  │ Shield │ DDoS protection service
                  └────────┘
```
<!--- edit this diagram with https://asciiflow.com  -->
## Getting started
### Bootstrapping
- Create a private S3 bucket and Dynamodb table to store you Terraform state and update the `Makefile` to reflect this
- You must enable a AWS shield advanced subscription manually on the account you would like to apply to. [Link to doc](https://docs.aws.amazon.com/waf/latest/developerguide/enable-ddos-prem.html)

### Terraform initialisation
- Use `make` with the `init_labs` or `init_live` target to ensure terraform is initialised correctly.
- Connect to desired workspace `terraform workspace select MyWorkSpaceName`

### Terraform contributing
- Use `terraform fmt --recursive .` to format any changes you've made.

## License
This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
