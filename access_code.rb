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
    @value = value.to_s.downcase
  end

  def blank?
    value.blank?
  end

  def ==(other)
    if blank? && other.blank?
      false
    else
      if !other.is_a?(AccessCode)
        other = AccessCode.new(other)
      end

      value == other.value
    end
  end

  protected

  attr_reader :value
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

  it "is equal even when casing differs" do
    forall(code: present_string) do |code:|
      expect(AccessCode.new(code.downcase)).to eq AccessCode.new(code)
      expect(AccessCode.new(code)).to eq AccessCode.new(code.downcase)
      expect(AccessCode.new(code.upcase)).to eq AccessCode.new(code)
      expect(AccessCode.new(code)).to eq AccessCode.new(code.upcase)
    end
  end

  it "is equal even if the compared value isn't an access code" do
    forall(code: present_string) do |code:|
      expect(AccessCode.new(code)).to eq code
    end
  end

  it "is not equal when comparing against nil" do
    forall(code: present_string) do |code:|
      expect(AccessCode.new(code)).not_to eq AccessCode.new(nil)
      expect(AccessCode.new(nil)).not_to eq AccessCode.new(code)
    end
  end

  it "is equal if the value is present and the same" do
    forall(code: present_string) do |code:|
      expect(AccessCode.new(code)).to eq AccessCode.new(code)
    end
  end

  def present_string
    alphanumeric_string.where(&:present?)
  end

  def empty_value
    one_of(constant(nil), constant(""), constant("\n"), constant("      "))
  end
end
