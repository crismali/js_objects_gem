require 'pry'
require 'rspec'
require 'active_support/all'
require_relative '../lib/prototype'

describe Prototype do
  let(:prototype) { Prototype.new }

  describe "#method_missing" do

    context "a 'method=' method is called on the object for the first time" do
      before { prototype.test = 'test' }

      it "creates a method= method" do
        expect(prototype).to respond_to(:test=)
      end

      it "creates a method with out the = sign" do
        expect(prototype).to respond_to(:test)
      end
    end

    it "returns nil when an unknown method is called" do
      expect(prototype.undefined).to be_nil
    end

    it "returns a default value if set when an unknown method is called" do
      prototype.default = 5
      expect(prototype.undefined).to eq(5)
      prototype.default_proc = Proc.new{ 7 }
      expect(prototype.undefined).to eq(7)
    end
  end
end
