
# public-artefact-store

### Purpose
This project was created as a simple way to serve public artifacts on AWS after [our previous solution was sunset](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/).

Some configuration may be specific to our use-case, however the bulk of this Terraform is likely to be of use to others that want an easy way to serve static files on AWS

## Getting started
### Bootstrapping
- Create a private s3 bucket and dynamodb_table to store you tf state and update the `Makefile` to reflect this

### Terraform initialisation
- Use `make` with the `init_labs` or `init_live` target to ensure terraform is initialised correctly.

## License
This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
