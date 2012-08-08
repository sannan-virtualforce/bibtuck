namespace :photos do

  desc "Recreate all photo versions"
  task :recreate_versions => :environment do
    Photo.all.each do |photo|
      photo.path.recreate_versions!
      photo.save
    end
  end

end
