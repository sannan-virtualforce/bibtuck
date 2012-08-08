before  "deploy:setup"      ,   "db:remote:generate_config"
after   "deploy:update_code",   "db:remote:symlink"

namespace :db do

  namespace :remote do
    set :db_name do
      Capistrano::CLI.ui.ask "Enter database name for #{rails_env} environment:"
    end

    set :db_user do
      Capistrano::CLI.ui.ask "Enter database user:"
    end

    set :db_pass do
      Capistrano::CLI.password_prompt 'Enter database password:'
    end

    set :db_host do
      database_host.empty? ? 'localhost' : database_host
    end

    set :database_host do
      host = Capistrano::CLI.ui.ask "Enter database host (default 'localhost'):"
    end

    desc "Generate config/database.yml"
    task :generate_config, :roles => :app do
      database_configuration = ERB.new <<-EOF
#{rails_env}:
  adapter: postgresql
  database: #{self.send("db_name")}
  username: #{self.send("db_user")}
  password: #{self.send("db_pass")}
  host: #{self.send("db_host")}
  port: 5432
  encoding: utf8
EOF
      run "mkdir -p #{deploy_to}/#{shared_dir}/config"
      put database_configuration.result, "#{deploy_to}/#{shared_dir}/config/database.yml"
    end

    desc "Make symlink for config/database.yml"
    task :symlink do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end

  desc "Create database"
  task :create, :roles => :db do
    rake = fetch(:rake, "rake")
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:create"
  end

  desc "Run rake db:schema:load"
  task :schema_load, :roles => :db, :only => { :primary => true } do
    rake = fetch(:rake, "rake")
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:schema:load"
  end

end
