require 'pry'
require 'rspec'
require_relative '../lib/object'
require_relative '../lib/js_object'

describe JsObject do

  let(:obj) { JsObject.new }

  describe '#method_missing' do

    context "a 'method=' method is called on the object for the first time" do
      before { obj.test = 'test' }

      it "creates a method= method" do
        expect(obj).to respond_to(:test=)
      end

      it "creates a method with out the = sign" do
        expect(obj).to respond_to(:test)
      end
    end

    context "method= is called but not for the first time" do

      it "sets a new value that can be retrieved by 'method'" do
        obj.test = 5
        expect(obj.test).to eq(5)
        obj.test = false
        expect(obj.test).to be_false
        obj.test = nil
        expect(obj.test).to be_nil
      end
    end

    context "an unknown method that doesn't end with an = is called" do

      it "returns the value that was set previously" do
        obj.test = 5
        expect(obj.test).to eq(5)
        obj.test = false
        expect(obj.test).to be_false
        obj.test = nil
        expect(obj.test).to be_nil
      end

      context "when the value set was a proc" do
        let(:proc) { Proc.new { |a| a + self.test } }

        it "calls the proc in the context of the object" do
          obj.test = 2
          obj.proc = proc
          expect(obj.proc(1)).to eq(3)
        end
      end
    end
  end

  describe 'prototype property' do
    let(:parent_obj) { JsObject.new }

    it "has a prototype that can be set via prototype=" do
      obj.prototype = parent_obj
      expect(obj.prototype).to eq(parent_obj)
    end

    it "has a prototype that can be set via [:prototype]=" do
      obj[:prototype] = parent_obj
      expect(obj.prototype).to eq(parent_obj)
    end

    it "has a prototype that can be set via ['prototype']=" do
      obj['prototype'] = parent_obj
      expect(obj.prototype).to eq(parent_obj)
    end

    context "an object lacks a property and it's delegated to its prototype" do
      before do
        obj.prototype = parent_obj
      end

      it "executes a proc set on the prototype in context of the current object only" do
        parent_obj.set_test = Proc.new { self.test = 'test' }
        obj.set_test
        expect(obj.test).to eq('test')
        expect(parent_obj.test).to be_nil
      end

      it "returns the value set on it's prototype but doesn't set it on the object itself" do
        parent_obj.test = 5
        expect(obj.test).to eq(5)
        obj.prototype = OBJECT
        expect(obj.test).to be_nil
      end
    end
  end

  describe "#[]" do

    it "returns the value set at the key (string)" do
      obj.test = 5
      expect(obj['test']).to eq(5)
      expect(obj[:test]).to eq(5)
      obj.test = false
      expect(obj['test']).to be_false
      expect(obj[:test]).to be_false
      obj.test = nil
      expect(obj['test']).to be_nil
      expect(obj[:test]).to be_nil
    end


    it "returns the value set at the key (symbol)" do
      obj.test = 5
      expect(obj[:test]).to eq(5)
      obj.test = false
      expect(obj[:test]).to be_false
      obj.test = nil
      expect(obj[:test]).to be_nil
    end

    context "when the value is not set on the object but it is on the prototype" do
      let(:parent_obj) { JsObject.new }
      before { obj.prototype = parent_obj }

      it "returns the value held by the prototype" do
        expect(obj[:test]).to be_nil
        parent_obj.test = 5
        expect(obj[:test]).to eq(5)
      end

      it "returns a proc when it's been set on it's prototype" do
        expect(obj[:test]).to be_nil
        proc = Proc.new { 5 }
        parent_obj.test = proc
        expect(obj[:test]).to eq(proc)
      end
    end

  end

  describe "#[]=" do
    it "sets the value on the object" do
      expect(obj[:test]).to be_nil
      obj[:test] = 5
      expect(obj[:test]).to eq(5)
      obj[:test] = 'test'
      expect(obj[:test]).to eq('test')
      obj[:test] = false
      expect(obj[:test]).to eq(false)
      obj[:test] = nil
      expect(obj[:test]).to eq(nil)
    end

    it "sets up getter and setter methods for the key" do
      obj[:unlikely_key_name] = 'test'
      expect(obj).to respond_to :unlikely_key_name
      expect(obj.unlikely_key_name).to eq('test')
      expect(obj).to respond_to :unlikely_key_name=
      obj.unlikely_key_name = 'other string'
      expect(obj.unlikely_key_name).to eq('other string')
    end

    context "when the value is a proc" do
      let(:proc) { Proc.new { self.test = 'test' } }
      before { obj[:proc] = proc }

      it "sets the value when the value is a proc" do
        expect(obj[:proc]).to eq(proc)
      end

      it "can call the proc in the context of itself through a 'method' call" do
        expect(obj).to respond_to :proc
        obj.proc
        expect(obj.test).to eq('test')
      end
    end
  end

  describe "#delete" do

    it "removes the property from the object's falsey lists" do
      obj.false_test = false
      obj.nil_test = nil
      obj.delete :nil_test
      obj.delete 'false_test'
      nil_list = obj.instance_eval { nil_keys }
      false_list = obj.instance_eval { false_keys }
      expect(nil_list).to_not include :nil_test
      expect(false_list).to_not include :false_test
    end

    it "removes the setter and getter methods" do
      obj.test = 'test'
      obj.delete :test
      expect(obj).to_not respond_to :test
      expect(obj).to_not respond_to :test=
    end
  end
end
