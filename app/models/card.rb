class Card < ApplicationRecord
  include CalculationTitleScore
  belongs_to :person

  scope :name_like, -> name {
    where('name like ?', "%#{name}%").or(where('organization like ?', "%#{name}%"))
  }

  def fix_name
    self.name = name.gsub(/[\s]+/, "")
    self.email = email.downcase
    return self
  end

  def self.calc(title_a, title_b)
    score = self.new
    return score.calculation(title_a, title_b)
  end
end