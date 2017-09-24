require 'test_helper'

class SingleRecordFormTest < Minitest::Test

## Test Implementation Classes #################################################

  class NoRecordClassForm < Kaishiki::SingleRecordForm
    attribute :some_attr
    attribute :another_attr
  end


  class AuthorForm < Kaishiki::SingleRecordForm
    for_record Author

    attribute :email
    normalize :email, with: :email
    normalize :email
    # Intentional absence of validations for email attribute.

    attribute :first_name
    normalize :first_name
    validates :first_name, presence: true

    attribute :surname
    normalize :surname
    validates :surname, presence: true

    attribute :sign_in_count
    validates :sign_in_count, presence: true, numericality: true

    directly_assign :email,
                    :first_name,
                    :surname => :last_name
  end


## Test Cases ##################################################################

  test "cannot use default initialize without using for_record" do
    assert_raises(NotImplementedError) do
      NoRecordClassForm.new
    end
  end

  test "initializes a new record when record class is set via for_record" do
    form = AuthorForm.new
    assert_kind_of(Author, form.record)
    assert_equal(true, form.record.new_record?)
    assert_equal(0, form.record.sign_in_count)
  end


  test "copies initial values from a wrapped record based on directly_assign" do
    author1 = Author.find(1)
    author2 = Author.find(2)
    form1   = AuthorForm.new(author1)
    form2   = AuthorForm.new(author2)

    assert_equal(author1.email,         form1.email)
    assert_equal(author1.first_name,    form1.first_name)
    assert_equal(author1.last_name,     form1.surname)
    refute_equal(author1.sign_in_count, form1.sign_in_count)

    assert_equal(author2.email,         form2.email)
    assert_equal(author2.first_name,    form2.first_name)
    assert_equal(author2.last_name,     form2.surname)
    refute_equal(author2.sign_in_count, form2.sign_in_count)
  end


  test "apply_direct_assignments maps values from form to record" do
    author  = Author.find(1)
    form    = AuthorForm.new(
                author,
                first_name: "Updated",
                surname:    "Name",
                sign_in_count: 5)

    # Initially, values are set on form...
    assert_equal("Updated", form.first_name)
    assert_equal("Name",    form.surname)
    assert_equal(5,         form.sign_in_count)

    # ...and values are not set on record.
    assert_equal("waytogootto@example.com", author.email)
    assert_equal("Otto",                    author.first_name)
    assert_equal("Valdez",                  author.last_name)
    assert_equal(2,                         author.sign_in_count)

    # Then calling #apply_direct_assignments...
    form.send(:apply_direct_assignments)

    # ...applies select values onto the record.
    assert_equal("waytogootto@example.com", author.email)
    assert_equal("Updated",                 author.first_name)
    assert_equal("Name",                    author.last_name)
    assert_equal(2,                         author.sign_in_count)
  end


  test "propagate_errors will copy model validation errors up to the form" do
    author  = Author.find(1)
    form    = AuthorForm.new(
                author,
                email: "",
                sign_in_count: author.sign_in_count)

    # Initial valid value
    assert_equal("waytogootto@example.com", form.record.email)
    # Applying form values
    form.send(:apply_direct_assignments)
    # Now an invalid value
    assert_nil(form.record.email)

    # Now the weird part: a valid form wrapping an invalid record.
    # This is simulating a form with poorly-considered business logic, that is
    # to say: the form does not maintain the validity invariants of the record.
    assert(form.valid?)
    refute(form.record.valid?)

    # Form will not have the :email key on its list of errors...
    refute_includes(form.errors.keys, :email)
    # ...but its record will.
    assert_includes(form.record.errors.keys, :email)

    # After calling #propagate_errors however...
    form.send(:propagate_errors)
    # ...the error appears on the form.
    assert_includes(form.errors.keys, :email)
  end

end
