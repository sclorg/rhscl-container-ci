# sclorg repositories permissions test

This directory contains job configuration file, managed through [Jenkins Job
Builder](http://ci.openstack.org/jenkins-job-builder/).

Created job checks that only employees of Red Hat have push or admin
permissions in repositories for container images in sclorg github
organization.

## Jenkins environment requirements

* environmental variable GH_ACCESS_TOKEN which contains token for github user who has access to checked repositories
* "json", "rest_client", "i18n" and "ldap" gems
* connection to RH VPN (to access ldap.rdu.redhat.com)

## Pre-requisites

* installed jenkins-jobs command
* configuration file for Jenkins Job Builder

## Testing job modifications

    jenkins-jobs --conf <config file> test sclorg-permissions-test.yaml

This prints XML definition of the job to STDOUT.

## Updating jobs

The provided script can update the Jenkins jobs over the API by running JJB.

    jenkins-jobs --conf <config file> update sclorg-permissions-test.yaml

## Generated jobs

* *SCLo-test-github-permissions*: a job which checks github repositories permissions.
