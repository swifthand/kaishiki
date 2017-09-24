require 'test_helper'

##
# An example of a fleshed-out set of interactions with an example form object,
# which has a commit method and several sets of custom attributes that do not
# map directly onto the underlying record.
class MapFormTest < Minitest::Test

## Test Implementation Class ###################################################

  class MapForm < Kaishiki::SingleRecordForm

    attribute :author, Author
    validates :author, presence: true

    attribute :coordinates, Kaishiki::JSON, default: {}
    validates :coordinates, presence: true

    attribute :units, String
    normalize :units
    validate  :units_in_unit_list

    attribute :type, String, default: "political"
    normalize :type
    validates :type, presence: true

    for_record Map

    directly_assign :author,
                    :units,
                    :type => :category

    def initialize(record = default_new_record, **attributes)
      super(record, **attributes)
      self.coordinates = whitelist_coordinate_keys(coordinates)
    end

    def commit
      return false if invalid?
      apply_direct_assignments
      assign_coordinates
      propagate_errors if record.invalid?
      record.save
    end

  private

    def units_in_unit_list
      unless %w[ mi km m ft ].include?(units)
        errors.add(:units, "is not a valid unit of distance")
      end
    end

    def whitelist_coordinate_keys(coords)
      coordinates.stringify_keys.slice('latitude', 'longitude')
    end

    def assign_coordinates
      record.center_latitude  = coordinates.fetch('latitude',  nil)
      record.center_longitude = coordinates.fetch('longitude', nil)
    end

  end


## Test Cases ##################################################################


  test "creating a new map" do
    author  = Author.find(2)
    form    = MapForm.new(
      author: author,
      coordinates: '{"latitude": -33.420928,"longitude": -70.610337}',
      type: 'rainfall',
      units: 'm'
    )

    assert(form.commit)

    record = Map.find(form.record.id)
    assert_equal(author,      record.author)
    assert_equal(-33.420928,  record.center_latitude)
    assert_equal(-70.610337,  record.center_longitude)
    assert_equal('rainfall',  record.category)
    assert_equal('m',         record.units)
  end


  test "failing to create a new map" do
    author  = Author.find(2)
    form    = MapForm.new(
      author: author,
      coordinates: { longitude: nil },
      type: '',
      units: 'cm'
    )
    refute(form.commit)

    assert_includes(form.errors.keys, :units)
    assert_includes(form.errors.keys, :type)
  end


  test "updating a map" do
    prev_author = Author.find(1)
    new_author  = Author.find(2)
    map         = Map.find(1)
    form        = MapForm.new(
      map,
      author: new_author,
      coordinates: { latitude: -33.420928, longitude: -70.610337 },
      # Intentionally not providing a new value for type/category.
      units: 'm'
    )
    assert(form.commit)

    record = Map.find(1)
    assert_equal(new_author,  record.author)
    assert_equal('political', record.category)
    assert_equal('m',         record.units)
    assert_equal(-33.420928,  record.center_latitude.to_f)
    assert_equal(-70.610337,  record.center_longitude.to_f)
  end


  test "failing to update a map" do
    prev_author = Author.find(1)
    new_author  = Author.find(2)
    map         = Map.find(1)
    form        = MapForm.new(
      map,
      author: new_author,
      coordinates: { longitude: nil, latitude: 'roflcopter' },
      type: 'rainfall',
      units: 'm'
    )
    refute(form.commit)

    assert_includes(form.errors.keys, :center_latitude)
    assert_includes(form.errors.keys, :center_longitude)

    record = Map.find(1)
    assert_equal(prev_author, record.author)
    assert_equal('political', record.category)
    assert_equal('mi',        record.units)
    assert_equal(29.7601927,  record.center_latitude.to_f)
    assert_equal(-95.3693896, record.center_longitude.to_f)
  end

end
