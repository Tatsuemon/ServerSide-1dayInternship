class Person < ApplicationRecord
  has_many :cards, dependent: :destroy

  scope :has_like, -> name {
    includes(:cards).merge(Card.name_like name).references(:card)
  }
end