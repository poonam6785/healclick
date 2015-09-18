HealClick Readme

### Set up project locally:

1. Create config/database.yml file using config/database.yml.sample
2. Load database from db dump
3. run `bundle` and `rake db:migrate`
3. Start packaged solr with `rake sunspot:solr:start`
5. Start app server

### Deploy project to existing server (assuming you have project installed):

1. Configure your private key by running
eval `ssh-agent -s`
ssh-add {/path/to/your/private/key}
so that you can ssh to server with user ubuntu

2. specify branch name in config/deploy/{server_name}.rb
  you may want to start with
  config/deploy/aws_staging.rb

3. Specify locations of your private keys to application and git servers in private_key and git_private_key variables
of config/deploy.rb
    * private_key is your ssh key for healclick server (usually this is ~/.ssh/HealClickJoey.pem). Not needed for deploy. This key is used by tasks setup:install_packages, setup:s3, rails:console and rails:runner.  If your deploy fails with authentication issue, it has nothing to do with this variable. Check your ssh config instead. See config/deploy/ssh_config for example ssh config file.
    * git_private_key is a key that should be added as a deploy key in bitbucket repository. Usually this it ~/.ssh/healclick_deploy. This key is used by deploy script to checkout desired version of app from git to server.

4. cap setup:upload_git_key (only if you added your key to bitbucket repository. This task will try to upload key specified by git_private_key variable to server via scp. You don't need to do it if you're using key that's already on server)

5.  run `cap {server_name} deploy` (where server_name is: aws_staging for staging, production for production)
  example:
    cap aws_staging deploy

  to roll back deploy, user `cap {server_name} deploy:rollback`

### Deployment details

1. App runs on ruby 2.0 and Rails 4.0. Tho change it, edit rvm_ruby_string and passenger_ruby variables in config/deploy.rb, then run `cap {server_name} setup:update_nginx_config` and `cap {server_name} deploy`.

1. App is deployed to /apps/healclick. Setup is standard for a Capistrano app. Notable directories are:
    * /apps/healclick/current - source code of current release (symlink to latest folder in /apps/healclick/releases)
    * /apps/healclick/shared/config - config files. database.yml and other sensitive config files shouild not be stored in git and uploaded securely to server via scp. Those files are then symlinked by deploy:symlink_configs task in config/deploy.rb
    * /apps/healclick/shared/log - log files. Logs are rotated by logrotate (see config/deploy/logrotate_healclick and config/schedule.rb). To view live log file, use `cap {server_name} logs:application`.
    * /apps/healclick/shared/backups - database backups produced by `cap db:backup` task

2. Both production and staging environments use RDS MySQL database. See database passwords in config files stored in /apps/healclick/shared/config on server. Note that RDS database will only accept connections from within its security group, so you have to access it from ec2 instance. Use `cap {server_name} db:backup` to get database dump. Database is backed up automatically by RDS, use its 'restore to point in time' mechanism to restore it.

2. Elasticache is used as a cache storage on production. It's compatible with memcached and can be replaced with any memcached server. Use `Rails.cache.clear` to clear cache if needed.

2. Assets are stored on s3. Asset_sync automatically uploads assets to s3 on each deploy after asset:precompile task. Always use asset_url when referring to assets in image_tags, stylesheets, etc. E.g. background-image: asset_url('nav-icon.png');

3. Uploaded files are stored on s3. See config/aws_s3.yml and config/initializers/paperclip.rb for setup details. Remove assets_bucket from options in aws_s3.yml for desired environment to serve assets locally.

3. Delayed Job workers are started by task delayed_job:start_multiple. This task starts multiple DJ workers serving named queues according to delayed_job_queues var. Set this variable in config/deploy/aws_staging.rb and config/deploy/production.rb. It needs to be a hash where keys are queue names and values are worker counts (minimum 1). Example:
`set :delayed_job_queues, {patient_matches: 2, populate_patient_matches: 1, ongoing_jobs: 1}`

4. Crontab is updated on each deploy by whenever:update_crontab task according to content of config/schedule.rb. Use `cap {server_name} whenever:update_crontab` command to update it manually.

5. Websolr is used as search index on both production and staging instances. See config/sunspot.yml for endpoint details. Use `cap {server_name} solr:reindex` to run reindex. Websolr doesn't need to be restarted on deploy. Tasks `cap solr:stop` and `cap solr:start` work with Solr packaged in Sunspot gem.

6. NewRelic license key is specified in newrelic_license_key variable in config/deploy.rb. Use `cap setup:server_monitoring` to set up newrelic server monitoring for new server.

### Set up new server to deploy project (assuming you have a fresh ubuntu instance. Only works for Ubuntu for now):

1. Create file config/deploy/{server_name}.rb and specify parameters similar to other files in config/deploy.
2. Add server_name to stages variable in config/deploy.rb
3. Specify locations of your private keys to application and git servers in private_key and git_private_key variables of config/deploy.rb
3. run `cap {server_name} setup:install packages` to install needed Ubuntu packages. This task needs to be run separately from setup:server because it's interactive. See source code for package list
4. run `cap {server_name} setup:server`. This task will:
    * install and configure rvm
    * upload your git key to server
    * create app directory structure under /apps/healclick
    * install bundler
    * install nginx and configure it using config/deploy/nginx as nginx config and template from config/deploy/nginx.{environment}.rb as application server config
    * upload configs specified in config_files variable to /apps/healclick/shared/config folder on server. You can use this to upload database.yml and other sensitive configs to server securely
6. run `cap deploy` to deploy project for the first time

### Scale producition application

1. Set up new server and deploy application there
2. Add new server to :app and :web roles in config/deploy/production.rb
3. Add new server to load balancer in EC2 console
4. Point healclick.com and www.healclick.com to load balancer endpoint in Cloudflare (only if currently pointed to EC2 instance endpoint)

NOTE: Role :delayed_job specifies which server (or servers) will be used to run delayed jobs. Role :db specifies which server will be used to run migration scripts and stuff like that (since RDS is used as actual DB server). You can use app servers for these roles.

**IMPORTANT:** make sure application is deployed within one Amazon cluster. All EC2 instances, RDS instances, S3 buckets, Elasticache instances and Websolr should all belong to one amazon cluster, otherwise there will be performance issues and fees for data transfer between clusters.
