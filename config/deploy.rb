set :application, "bibandtuck"
set :assets_path, File.join('public', 'assets')
set :repository, "deploy@bibandtuck.com:~/bibtuck_com"  # Your clone URL
set :scm, :git
set :user, "deploy"
set :branch, "master"
set :deploy_via, :remote_cache
set :use_sudo, true
ssh_options[:forward_agent] = true

set :stages, %w(staging production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test:development"
  end
end

task :symlink_configs do
  run "ln -nfs #{shared_path}/config/endicia.yml #{release_path}/config/endicia.yml"
end

after 'deploy:update_code', 'bundler:bundle_new_release'
after 'deploy:update_code', 'symlink_configs'

#desc "symlink shared files"
#task :symlink_shared do
#  run "ln -nfs #{shared_path}/public/assets #{File.join(deploy_to, 'current', assets_path)}"
#  run "ln -nfs #{shared_path}/public/uploads #{File.join(deploy_to, 'current', 'public', 'uploads')}"
#end
#
#after 'deploy:update_code', 'symlink_shared'

after 'deploy', 'deploy:cleanup'

namespace :mailman do
  desc "Mailman::Start"
  task :start, :roles => [:app] do
    run "cd #{current_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon start"
  end

  desc "Mailman::Stop"
  task :stop, :roles => [:app] do
    run "cd #{current_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon stop"
  end

  desc "Mailman::Restart"
  task :restart, :roles => [:app] do
    mailman.stop
    mailman.start
  end
end
