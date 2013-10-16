# encoding: utf-8
require 'capistrano'
require 'colored'
require 'json'

def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

Capistrano::Configuration.instance.load do
  _cset(:jenkins_url) {
    abort "Please specify the jenkins URL eiter in :jenkins_url or in environment JENKINS_URL, http://username:password@jenkins.com".red if ENV['JENKINS_URL'].nil?
    ENV['JENKINS_URL']
  }

  _cset(:jenkins_job_name) { abort "Please specify the jenkins job name, set :jenkins_job_name".red }
  _cset(:branch) { abort "Please specify :branch, needed to find correct build".red }

  _cset(:jenkins_retry_sleep, 10)

  def fetch_json(url)
    response = `curl -s #{url}`
    json = JSON.load(response)
  end

  def get_build(sha, data)
    data['builds'].each do |build|
      build['actions'].each do |action|
        next unless action.has_key?('lastBuiltRevision')
        return build if action['lastBuiltRevision']['SHA1'].chomp == sha.chomp
      end
    end
    false
  end

  def agree(message)
    Capistrano::CLI.ui.agree message
  end

  def trigger_build
    `curl -s #{jenkins_url}/job/#{jenkins_job_name}/build`
  end

  namespace :jenkins do
    desc "Check jenkins build status"
    task :verify_build, :except => { :no_release => true } do
      retrying = false
      [0].each do |i|
        sha = `git ls-remote #{repository} #{branch}`.sub!(/\s+.*$/, '').chomp
        puts "First sha #{sha}"
        #if it was a tag we need to get the sha to the commit
        sha = `git log --pretty=format:'%H' -n1 #{sha}`.chomp
        puts "Second sha #{sha}"
        build = get_build(sha, fetch_json("#{jenkins_url}/job/#{jenkins_job_name}/api/json?depth=1"))

        unless build then
          trigger_new_build = agree "Couldn't find a build with sha #{sha} on jenkins. Do you want to trigger build? yes/no: "
          if trigger_new_build then
            trigger_build
            sleep jenkins_retry_sleep
            redo
          else
            abort
          end
        end

        if build['building'] and not retrying then
          retrying = agree "The requested revision is currently building, Retry? yes/no: "
          if retrying then
            puts "Retrying in #{jenkins_retry_sleep} seconds."
            sleep jenkins_retry_sleep
            redo
          end
        elsif build['building'] and retrying
          puts "Still in build progress.. will retry in #{jenkins_retry_sleep} seconds."
          sleep jenkins_retry_sleep
          redo
        end

        abort "Build for requested release was not successful, cant deploy. Build result was #{build['result']}".red unless build['result'] == "SUCCESS"
        puts "✔ jenkins build verified for revision #{sha}".green
      end
    end
  end

end
