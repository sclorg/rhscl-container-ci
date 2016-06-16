CI Tests for Container Images Based on Red Hat Software Collections
===================================================================

This repository includes necessary metadata to test Container Images
Based on Red Hat Software Collections automatically, prefferably using
Jenkins.


Content of this repository
--------------------------

* [CentOS CI Jenkins Configuration](centos-ci-jenkins) -- set of scripts
and configuration for those scripts to generate set of Jenkins Job Builder
configs for CentOS CI, that are supposed to test GitHub pull-requests
of Contaienr Images repositories.

* [sclorg repositories permissions test](sclorg-permissions-test) -- scripts
and Jenkins Job Builder configuration for job which test sclorg
repositories permissions. It checks that only employees of Red Hat have
push or admin permissions in repositories for container images in
sclorg github organization.
