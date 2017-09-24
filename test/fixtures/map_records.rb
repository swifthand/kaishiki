module MapRecords

  def self.create!
    maps_attributes.each do |attrs|
      Map.create(attrs)
    end
  end


  def self.maps_attributes
    [ { id:               1,
        category:         'political',
        center_latitude:  29.7601927,
        center_longitude: -95.3693896,
        units:            'mi',
        author_id:        1,
      },
      { id:               2,
        category:         'topograpical',
        center_latitude:  29.7601927,
        center_longitude: -95.3693896,
        units:            'km',
        author_id:        1,
      },
    ]
  end

end
