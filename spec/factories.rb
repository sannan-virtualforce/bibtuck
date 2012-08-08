FactoryGirl.define do

  factory :user do
    first_name  'John'
    last_name   'Doe'
    email       'john@example.com'
    username    'superduper'
    password    'awesomepass'
  end

  factory :item do
    name        'Awesome Item'
    category
    size        '0'
  end

  factory :category do
    name        'Pants'
    box_type    'a'
  end

end
