# capistrano-jenkins

Capistrano recipe to verify build status on Jenkins

## Installation

	gem install capistrano-jenkins

## Options

**:jenkins_url**

URL to jenkins, for password protected use format "http://username:pass@my.jenkins.com".

By default it will check for the URL in the environment variable JENKINS_URL.

**:jenkins_job_name**

The job name on jenkins

**:jenkins_retry_sleep**

How long between retries if build currently in progress.

## Usage

Include the recipe

	require 'capistrano-jenkins'

Set required parameters

	set :branch, "master"
	set :jenkins_job_name, "MyProject"
	set :jenkins_url, "http://username:pass@my.jenkins.com"


Add the task, e.g on before

	before "jenkins:verify_build"
