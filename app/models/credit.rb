class Credit < ActiveRecord::Base
  belongs_to :user
  has_one :buck_transaction, :as => :reference

  validates_numericality_of :bucks
  validates_presence_of :user

  after_create do
    self.class.transaction do
      Notification.create!(
        :template => 'credit',
        :user     => user,
        :subject  => self,
        :actor    => User.admin,
        :origin   => self
      )

      BuckTransaction.create!(:reference => self,
                              :user => user,
                              :reason =>  :credit,
                              :delta => bucks)
    end
  end
end
