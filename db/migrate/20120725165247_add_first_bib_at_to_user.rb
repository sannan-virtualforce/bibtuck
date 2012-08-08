class AddFirstBibAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :first_bib_at, :datetime
    User.all.each do |user|
      first_bib_at = user.items.where(:bibbed_at.ne => nil).minimum(:bibbed_at)
      if first_bib_at
        user.update_attribute :first_bib_at, first_bib_at
      end
    end
  end

  def self.down
    remove_column :users, :first_bib_at
  end
end
