module AuthorRecords

  def self.create!
    authors_attributes.each do |attrs|
      Author.create(attrs)
    end
  end


  def self.authors_attributes
    [ { id:                 1,
        email:              "waytogootto@example.com",
        first_name:         "Otto",
        last_name:          "Valdez",
        sign_in_count:      2,
      },
      { id:                 2,
        email:              "gendoarrighetti@example.com",
        first_name:         "Gendo",
        last_name:          "Arrighetti",
        sign_in_count:      0,
      },
    ]
  end

end
