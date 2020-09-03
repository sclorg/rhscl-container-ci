#!/bin/bash
#
# Install and run Jenkins Job Builder (JJB) and against Jenkins configured in jenkins_jobs.ini
# and jenkins_jobs_rhscl.ini files.

THISDIR=$(dirname ${BASH_SOURCE[0]})

if [[ -z "$JENKINS_CMD" ]]; then
  echo "You have to specify command as JENKINS_CMD environment variable."
  exit 1
fi

# Generate a JJB config files
if [ ! -f $THISDIR/jenkins_jobs.ini ] || [ ! -f $THISDIR/jenkins_jobs_rhscl.ini ]; then
  if [ ! -f $THISDIR/jenkins_jobs.ini ]; then
    cp $THISDIR/jenkins_jobs.ini.template $THISDIR/jenkins_jobs.ini
    echo "jenkins_jobs.ini generated, please edit and add username/password to update ci.centos.org"
  fi
  if [ ! -f $THISDIR/jenkins_jobs_rhscl.ini ]; then
    cp $THISDIR/jenkins_jobs.ini.template $THISDIR/jenkins_jobs_rhscl.ini
    echo "jenkins_jobs_rhscl.ini generated, please edit jenkins URL and add username/password to authenticate"
  fi
  exit 1
fi

# Generate jobs from collection list
cat $THISDIR/configuration | while read scl namespace gituser gitproject trigger hub_namespace; do
  yaml=$THISDIR/yaml/jobs/collections/${scl}-${namespace}.yaml
  [ -f $yaml ] || \
    sed "s/%SCL%/${scl}/g; s/%NAMESPACE%/${namespace}/g; s|%GITUSER%|${gituser}|g; s|%GITPROJECT%|${gitproject}|g; s|%TRIGGER%|${trigger}|g; s|%HUB_NAMESPACE%|$hub_namespace|g;" \
      $THISDIR/yaml/jobs/collections/template > $yaml
done

# Pass all other arguments through to JJB
if [ $# -eq 1 ]; then
  action=$1
  shift
  [[ "${action}" == "update" ]] || [[ "${action}" == "test" ]] \
    || [[ "${action}" == "delete" ]] || (jenkins-jobs ${action} $* && exit)
  echo "Updating 'SCLo*' jobs ..."
  jenkins-jobs --conf $THISDIR/jenkins_jobs.ini $action -r $THISDIR/yaml SCLo\* $*
  echo "Updating 'rhscl*' jobs ..."
  jenkins-jobs --conf $THISDIR/jenkins_jobs_rhscl.ini $action -r $THISDIR/yaml rhscl\* $*
elif [ $# -eq 2 ]; then
  action=$1
  shift
  [[ "${action}" == "update" ]] || [[ "${action}" == "test" ]] \
    || [[ "${action}" == "delete" ]] || (jenkins-jobs ${action} $* && exit)
  name=$1
  shift
  if [[ "${name}" == SCLo* ]]; then
    echo "Updating '${name}' jobs ..."
    jenkins-jobs --conf $THISDIR/jenkins_jobs.ini $action -r $THISDIR/yaml ${name} $*
  elif [[ "${name}" == rhscl* ]]; then
    echo "Updating '${name}' jobs ..."
    jenkins-jobs --conf $THISDIR/jenkins_jobs_rhscl.ini $action -r $THISDIR/yaml ${name} $*
  else
    echo "WARNING: Please specify 'SCLo' of 'rhscl' prefix for job names to choose right JJB configuration file. Passing all arguments directly to jenkins-jobs command"
    jenkins-jobs ${action} ${name} $*
  fi
else
  jenkins-jobs $*
fi

# vim: set ts=2 sw=2 tw=0 :
