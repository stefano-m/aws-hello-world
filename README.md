# An AWS Hello World Service

Hello World is a Web Service that greets everyone.

The service exposes a single endpoint `/hello` that accepts `GET` requests and
returns a `text/plain` response consisting of the phrase `hello, world!` and
the current date and time.

For example:

``` http
GET /hello

hello, world! 10/Nov/2020:20:52:11 +0000
```

The service is comprised of an AWS REST API Gateway with a single entry
point. Nothing else is needed. The entry point uses a [mock
integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html)
configured with a mapping template so that the appropriate response is
returned.

Preliminary tests have shown that with a load of 7,000 requests/second the 95th
percentile of the network latency is around 2.1 ms. This has been done with
both client and service within the same geographical region.

The approach taken has the following advantages:

- cost-effective
- reduced maintenance burden
- easy to extend and modify
- HTTPS by default
- low-latency

The price we pay is that we are tied to AWS and will need to design a different
solution if we wanted to move to another cloud provider. However, given the
simplicity of the service, I think it's worth it.

-----

**NOTE**

This configuration does **not** set up a custom domain name, but uses the
default invocation URL that looks like
`https://<ID>.execute-api.<REGION>.amazonaws.com`. However, setting up a custom
domain name would not be too hard.

-----

## Logging, Monitoring and Alerting

The service logs to, and can be monitored with, CloudWatch. Again, although
this choice is tied to using AWS, the advantage is that there is no
infrastructure to manage.

Logging is configured with Terraform. Access logs are JSON-formatted to make
analysis with CloudWatch Logs Insights easier.

CloudWatch alerts have not been set up yet. They should be set up after
observing the system under load in the staging environment to have an idea of
the how it behaves.

It's advisable to alert on the following metrics:

1. Latency and IntegrationLatency: to catch issues with performance
2. 5XXError: to catch possible bugs with the service
3. 4XXError: to detect potential malicious activity

## Building

Pre-requisites:

- OS: GNU/Linux
- GNU coreutils (`grep`, `rm`, `sha256sum`, etc.)
- GNU Make 4.x
- curl
- zip

The provided [`Makefile`](./Makefile) is used to drive the deployment and
tests. If needed, it will download the supported version of Terraform to use.

For more information, run `make help` and refer to the [`Makefile`](./Makefile)
source.

The Terraform configuration is documented in
[`docs/README.md`](./docs/README.md). The documentation has been generated
using the `terraform-docs` utility.

The invocation URL can be obtained from the `api_url` terraform output, e.g. by
calling `make output`.

### Deploying

The service can be deployed with `make apply`, use the GNU Make variable
`tf-workspace` to select the deployment environment: development, staging,
production. The workspace name is also validated by Terraform itself (using a
special `null_resource`) to minimize the chance of mistakes.

-----

**NOTE**

The Terraform state is currently configured to use the **local** backend. That
is, the state file is saved on the local disk. For proper production-readiness,
an **S3** backend with encryption at rest and state locking should be used
instead.

-----

### Testing

This service is very simple, but that does not mean we should not test it!

After deploying, run `make test` to check that the service replies as expected.

You can test the system under load with `make load-test`.

The code is in the [`tests`](./tests) directory.

Test automation could be run like

``` shell
make tf-workspace=development validate apply test
```

## Further Improvements

Further improvements to the service and code base could be:

- set up an encrypted S3 backend with state locking for the Terraform state
- add tests to ensure that logs are delivered to CloudWatch
- set up CloudWatch Alarms and deliver notifications using the correct channels
  (e.g. live chat apps, email, etc.)
- set up CloudTrail to monitor activity at the AWS level
- set up a CI/CD pipeline
