# Docker Images Tests on ci.centos.org

This directory contains job configuration files, managed through [Jenkins Job
Builder](http://ci.openstack.org/jenkins-job-builder/) to run tests for each
software collection Docker image.

*View all CentOS7 tests at [SCLo on ci.centos.org](https://ci.centos.org/view/SCLo/).*

## Pre-requisites

* `virtualenv` command, supplied through the `python-virtualenv` RPM

JJB will be installed into a virtual environment under this directory, so is
safe to run on any system.

## Testing job modifications

    ./run.sh test -o /tmp/jobs

Check the script exited without any errors, and the XML definitions of the jobs
will be available in /tmp/jobs.

## Updating jobs

The provided script can update the Jenkins jobs over the API by running JJB.

    ./run.sh update

If you haven't run it before, it will fail with an authentication error:

    jenkins.JenkinsException: Error in request. Possibly authentication failed [401]: Invalid password/token for user

Edit the newly created `jenkins_jobs.ini` and add the username/password for
access to Jenkins, then re-run the command.  These credentials can be found in
the home directory on slave01.ci.centos.org.

## Generated jobs

Content of folder `./yaml/jobs/collections/` can be generated running `./run.sh`. It is generated from [configuration file](https://github.com/sclorg/rhscl-container-ci/blob/master/centos-ci-jenkins/configuration) - each line of this file has format: "name namespace github_org github_project triggering project".

For each project three jenkins jobs are generated:

* *SCLo-container-{name}-{namespace}*: job which tests content of pull requests in CentOS7. It requires to run on [CentOS CI infrastructure](https://ci.centos.org)).

* *rhscl-images-{name}-{namespace}*: job which tests content of pull requests in RHEL7. It requires to run on machine with access to RHEL7 Docker image.

* *rhscl-images-{name}-{namespace}-build*: job which after new commit to repository builds CentoOS7 based image and pushes it to Docker Hub. This job is *not* configured to use CentOS CI infrastructure.


During updating jobs you can select jobs by globbing. For example to update jobs configured for CentOS CI run

    ./run.sh update SCLo-*

or to update the rest of jobs in different jenkins instance, update your `jenkins_jobs.ini` file and run

    ./run.sh update rhscl-images-*

## How to add tests for a new image

When a new image is created and we want to add testing of if, we only need to add a new entry to `./configuration` file and re-generate jobs:

    ./run.sh test . rhscl-images* -o /tmp/jobs

Then a PR should include `./configuration` and the newly created file `./yaml/jobs/collections/<newspec>`.

In order to allow testing of the pull-requests, make sure the ci user on github has permissions to write to the new repository.
