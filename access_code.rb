require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "rspec"
  gem "prop_check"
  gem "activesupport"
end

require "active_support"
require "active_support/security_utils"
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

      ActiveSupport::SecurityUtils.secure_compare(value, other.value)
    end
  end

  alias_method :eql?, :==

  def hash
    if blank?
      nil.hash
    else
      value.hash
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

  it "is #equal? IFF object identity is the same" do
    forall(code: present_string) do |code:|
      item = AccessCode.new(code)

      expect(item).to be_equal(item)
      expect(item).not_to be_equal(AccessCode.new(code))
    end
  end

  it "is represented as a hash correctly" do
    forall(code: present_string) do |code:|
      expect(AccessCode.new(code).hash).to eq AccessCode.new(code).hash
      expect(AccessCode.new(code.downcase).hash).to eq AccessCode.new(code).hash
      expect(AccessCode.new(code).hash).to eq AccessCode.new(code.downcase).hash
      expect(AccessCode.new(code.upcase).hash).to eq AccessCode.new(code).hash
      expect(AccessCode.new(code).hash).to eq AccessCode.new(code.upcase).hash
      expect(AccessCode.new(code).hash).not_to eq AccessCode.new(" #{code}").hash

      hash = {}
      hash[AccessCode.new(code)] = 1
      hash[AccessCode.new(code)] = 2

      expect(hash.keys.count).to eq 1
    end
  end

  it "hashes the same for any empty value" do
    forall(left: empty_value, right: empty_value) do |left:, right:|
      expect(AccessCode.new(left).hash).to eq AccessCode.new(right).hash
      expect(AccessCode.new(left).hash).to eq AccessCode.new(left).hash
      expect(AccessCode.new(right).hash).to eq AccessCode.new(right).hash
    end
  end

  it "uses ActiveSupport::SecurityUtils to compare values" do
    result = double("compare result")
    allow(ActiveSupport::SecurityUtils).to receive(:secure_compare).with("foo", "bar").and_return(result)

    comparison = AccessCode.new("foo") == AccessCode.new("bar")

    expect(comparison).to eq result
  end

  def present_string
    alphanumeric_string.where(&:present?)
  end

  def empty_value
    one_of(constant(nil), constant(""), constant("\n"), constant("      "))
  end
end
