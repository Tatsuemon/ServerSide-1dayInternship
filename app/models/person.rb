class Person < ApplicationRecord
  has_many :cards, dependent: :destroy
end
