class Passion < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
end
