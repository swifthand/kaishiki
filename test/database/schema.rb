ActiveRecord::Schema.define do
  self.verbose = false

  create_table :authors, :force => true do |t|
    t.string  :email
    t.string  :first_name
    t.string  :last_name
    t.integer :sign_in_count, default: 0
  end

  create_table :maps, :force => true do |t|
    t.string  :category
    t.decimal :center_latitude
    t.decimal :center_longitude
    t.string  :units
    t.integer :author_id
  end

end
