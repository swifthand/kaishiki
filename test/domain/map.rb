##
# Everyone loves maps.
class Map < ActiveRecord::Base

  belongs_to :author

  validates :author,            presence: true
  validates :center_latitude,   presence: true, numericality: true
  validates :center_longitude,  presence: true, numericality: true
  validates :units,             presence: true
  validates :category,          presence: true

  def shows_roads?
    ['road', 'traffic', 'political'].include?(category)
  end

end
