set :rails_env, "production"

role :web, "vs137429.blueboxgrid.com"
role :app, "vs137429.blueboxgrid.com"
role :db,  "vs137429.blueboxgrid.com", :primary => true
