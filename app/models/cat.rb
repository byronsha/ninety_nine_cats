class Cat < ActiveRecord::Base

  CAT_COLORS = ["red", "blue", "green", "white", "black", "brown", "orange"]

  validates :birth_date, :color, :name, :sex, :description, presence: true
  validates :sex, inclusion: { in: ["M", "F"] }
  validates :color, inclusion: { in: CAT_COLORS }

  has_many :rental_requests,
    foreign_key: :cat_id,
    primary_key: :id,
    class_name: 'CatRentalRequest',
    :dependent => :destroy

  def cat_colors
    CAT_COLORS
  end
end
