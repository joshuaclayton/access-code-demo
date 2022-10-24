require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "rspec"
  gem "prop_check"
  gem "activesupport"
end

require "active_support"
require "active_support/core_ext"

class AccessCode
  def initialize(value)
    @value = value
  end

  def blank?
    value.blank?
  end
end

RSpec.describe AccessCode do
  include PropCheck
  include PropCheck::Generators

  it "is blank for all empty values" do
    forall(code: empty_value) do |code:|
      expect(AccessCode.new(code)).to be_blank
    end
  end

  it "is not blank for all present values" do
    forall(code: present_string) do |code:|
      expect(AccessCode.new(code)).not_to be_blank
    end
  end

  def present_string
    alphanumeric_string.where(&:present?)
  end

  def empty_value
    one_of(constant(nil), constant(""), constant("\n"), constant("      "))
  end
end
