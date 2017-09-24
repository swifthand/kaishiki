require 'test_helper'

class FormTest < Minitest::Test

## Test Implementation Classes #################################################

  class ContactForm < Kaishiki::Form

    attribute :name, String
    normalize :name
    validates :name, presence: true

    attribute :message, String
    normalize :message, with: :collapse_newlines
    normalize :message
    validates :message, presence: true

    attribute :email, String
    normalize :email, with: :email
    normalize :email
    validates :email, email_format: true

    attribute :birth_day, Integer

    attribute :birth_month, Integer

    attribute :birth_year, Integer
    validate  :birth_year_is_viable?

    attribute :age, Integer, default: 13 # Because COPPA lol?

    def birth_year_is_viable?
      unless !birth_year.nil? && birth_year <= Time.now.year && (Time.now.year - 150) <= birth_year
        errors.add(:birth_year, "is not the birth year for a living human.")
      end
    end

  end

## Test Cases ##################################################################

  test "combination of Normalizr and Virtus assigns attributes correctly" do
    form = ContactForm.new(
      name:         " Morgan Jones  ",
      message:      "It's your move, I've made up my mind\nTime is running out, make a move\nOh, we can go on, do you understand?\nIt's all in your hands, it's your-",
      email:        "MJONES@example . com",
      birth_month:  '08',
      birth_day:    8,
      birth_year:   '8'
    )

    assert_equal('Morgan Jones', form.name)
    assert_equal(8, form.birth_year)
    assert_equal(8, form.birth_month)
    assert_equal(8, form.birth_day)
    assert_equal('mjones@example.com', form.email)
    assert_equal(13, form.age)
  end


  test "forms can be valid" do
    form = ContactForm.new(
      name:         " Morgan Jones  ",
      message:      "It's your move, I've made up my mind\nTime is running out, make a move\nOh, we can go on, do you understand?\nIt's all in your hands, it's your-",
      email:        "MJONES@example . com",
      birth_month:  '08',
      birth_day:    8,
      birth_year:   '2008'
    )
    assert(form.valid?)
  end


  test "normalizing to blank and validating presence causes error" do
    form = ContactForm.new(
      name:    "",
      message: "    "
    )
    assert_equal(false, form.valid?, "Form should fail validations by having blank name and message.")
    assert_includes(form.errors.keys, :name)
    assert_includes(form.errors.keys, :message)
    assert_nil(form.message)
    assert_nil(form.name)
  end


  test "custom normalizers integrate correctly" do
    form = ContactForm.new(message: "a\n\nb\n\nc")
    assert_equal("a\nb\nc", form.message)
  end


  test "active model custom validations are available correctly" do
    form = ContactForm.new(email: 'foobar', birth_year: 100)
    assert_equal(false, form.valid?)
    assert_includes(form.errors.keys, :birth_year)
    assert_includes(form.errors.keys, :email)
  end

end
