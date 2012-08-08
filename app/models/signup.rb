class Signup
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :code, :registration_code

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  validate :registration_code_is_in_registration_codes_list
  def registration_code_is_in_registration_codes_list
    self.registration_code = RegistrationCode.where(:code => code).first

    if !registration_code.present? || !registration_code.can_use?
      errors.add(:code, 'registration code is invalid')
    end
  end

end
