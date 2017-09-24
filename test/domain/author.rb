class Author < ActiveRecord::Base

  has_many :maps

  validates :email,         presence: true
  validates :first_name,    presence: true
  validates :last_name,     presence: true
  validates :sign_in_count, presence: true

end
