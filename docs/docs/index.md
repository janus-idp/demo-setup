# :wrench: Assemble :wrench:

The Assemble platform is built on the back of [Janus IDP](https://github.com/janus-idp/redhat-backstage-build) and [Backstage](https://backstage.io/docs/overview/what-is-backstage), with the goal of helping application teams get started quicker.

## Why Should I use Assemble?

Assemble combines all of the required technologies used for creating a "golden path" for application deployment. It allows teams to very quickly get up and running with all the necessary items required in DevSecOps, while creating a tight inner development loop.

## Assemble Components

### Development

#### Janus IDP

The [Janus IDP](https://github.com/janus-idp/redhat-backstage-build)(i.e. Backstage) is the front end of our assemble platform. It gives insight into the components installed in our Clusters and how those components connect to one another.

Assemble also uses Janus plugins to allow for the rapid deployment of new components. With the click of a button application teams can create a new code base including repo, pipelines, security, Kubernetes objects and everything required for development and deployment into Openshift.

#### Developer Workspaces

The Assemble deployment includes integration with [CodeReady Worksapace](https://www.redhat.com/en/technologies/jboss-middleware/codeready-workspaces) allowing development teams to have instant access to an IDE preloaded with their new code and ready for development.

### Deployment

#### Openshift Pipelines(Tekton)

Assemble deploys a pipeline using [Openshift Pipelines](https://docs.openshift.com/container-platform/4.12/cicd/pipelines/understanding-openshift-pipelines.html)(Tekton) that run test and security scans on the code, as well as packaging the application and building/deploying the container image into a specified registry.

### Security

#### Red Hat SSO(Keycloak)

[Red Hat SSO](https://access.redhat.com/webassets/avalon/j/includes/session/scribe/?redirectTo=https%3A%2F%2Faccess.redhat.com%2Fproducts%2Fred-hat-single-sign-on)([Keycloak](https://www.keycloak.org/)) is an identity management platform that secures our services (such as backstage) using a range of Identity Providers

!!! note "Default Setup"
    By default assemble users GitHub as our Identity Provider