# This file should contain all the record creation needed
# to seed the database with its default values.
# The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

puts "Create a 'bib+tuck++' registration code"
code = 'bib+tuck++'
registration_code = RegistrationCode.
                      find_by_code(code) ||
                    RegistrationCode.create!(:code => code)

puts 'Adding users'

User.create!(
  :username              => 'sheen',
  :first_name            => 'Charlie',
  :last_name             => 'Sheen',
  :email                 => 'rohan.deshpande@gmail.com',
  :password              => '123123',
  :password_confirmation => '123123',
  :admin                 => true
)
User.create!(
  :username              => 'bibtuck',
  :first_name            => 'Bib',
  :last_name             => 'Tuck',
  :email                 => 'info@bibandtuck.com',
  :password              => '123123',
  :password_confirmation => '123123',
  :admin                 => true
)

Brand.create!(:name => "SomeBrand")

Address.create!(
  :first_name   => "Hello",
  :last_name    => "Delivery",
  :street_line1 => "123 fake street",
  :city         => "Some city",
  :state        => "A state",
  :zipcode      => '82468',
  :user         => User.find_by_username('sheen')
)

photo = Photo.create!(
  :path => File.open(File.join(Rails.root, 'db/data/boots.jpg'))
)

item = Item.create!(
  :name                  => "An Item",
  :category              => Category.first,
  :condition             => Item::CONDITIONS.first,
  :description           => "My item description",
  :size                  => 'n/a',
  :brand                 => Brand.first,
  :user                  => User.find_by_username('sheen'),
  :fit                   => Item::FITS.first,
  :price                 => 1,
  :shipping_from_address => Address.first,
  :photos                => [photo]
)

item.bib

ref = BuckPurchase.create!(
  :user            => User.find_by_username('sheen'),
  :first_name      => 'foo',
  :last_name       => 'bar',
  :bucks           => 100,
  :amount_in_cents => 0
)

BuckTransaction.create!(:delta     => 100,
                        :user      => User.find_by_username('sheen'),
                        :reason    => :new_user,
                        :reference => ref)
