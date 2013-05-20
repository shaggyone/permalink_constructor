# -*- encoding : utf-8 -*-
require 'spec_helper'
require "active_model"
require "active_model/validations"
require "active_record/callbacks"

describe PermalinkConstructor do
  let(:validate_uniqueness) { false }
  let(:allowed_chars)       { "_a-z0-9\\-\\/" }
  let(:increment)           { false }
  let(:scope)               { nil }
  let(:options) do
    {
      :validate_uniqueness => validate_uniqueness,
      :allowed_chars       => allowed_chars,
      :increment           => increment,
      :scope               => scope
    }
  end
  let(:clazz) do
    permalink_options = options
    name = "TestClass#{(Time.now.to_f * 10000000).to_i}"
    c = Class.new do
      include ActiveModel::Validations
      include ActiveRecord::Callbacks
      # include ActiveModel::Conversion
      # extend ActiveModel::Naming
      include PermalinkConstructor

      attr_accessor :id, :title_field, :permalink_field

      def initialize(attributes = {})
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end

      def persisted?
        false
      end

      def new_record?
        id.blank?
      end

      constructs_permalink_from :title_field, permalink_options.merge(:permalink_field => :permalink_field)
    end
    Object::const_set name, c
    c
  end

  context "Class definition" do
    subject { clazz }

    it { should be_respond_to(:permalink_options) }
    it { should be_respond_to(:permalink_source_field_name) }
    it { should be_respond_to(:permalink_field_name) }

    its(:permalink_options) { should be == options.merge(permalink_field: :permalink_field, title_field: :title_field) }
    its(:permalink_source_field_name) { should be == :title_field }
    its(:permalink_field_name) { should be == :permalink_field }
  end

  context "#generate_permalink" do
    subject { clazz.new title_field: 'Title value', permalink_field: permalink }

    after do
      subject.generate_permalink
    end

    context "permalink given" do
      let(:permalink) { "Some permalink value" }

      specify "Just filters permalink value" do
        subject.should_receive(:filter_permalink).with('Some permalink value').and_return('filtered_value')
        subject.should_receive("permalink_field=").with("filtered_value")
      end
    end

    context "no permalink given" do
      let(:permalink) { nil }
      specify "Constructs permalink from desired field" do
        subject.should_receive(:filter_permalink).with('Title value').and_return('filtered_value')
        subject.should_receive("permalink_field=").with("filtered_value")
      end
    end
  end

  context "#filter_permalink" do
    let(:obj) { clazz.new :permalink_field => text }
    subject { obj.filter_permalink(obj.permalink_field) }

    context "whitespaces converted to dashes" do
      let(:text) { "hello world  yea" }
      it { should be == 'hello-world--yea' }
    end

    context "cyrillic text transliteration" do
      let(:text) { "Привет мир" }
      it { should be == 'privet-mir' }
    end

    context "downcasing" do
      let(:text) { "Hello world" }
      it { should be == 'hello-world' }
    end

    context "filters non allowed chars" do
      let(:allowed_chars) { "hld91," }
      let(:text) { "hello world, 1997" }

      it { should be == 'hllld,199' }
    end

    context "trim slashes slashes" do
      let(:text) { "/hello/world/1997/" }

      it { should be == 'hello/world/1997' }
    end

    context "only slash" do
      let(:text) { "/" }

      it { should be == '/' }
    end
  end

  context "#add_permalink_suffix" do
    let(:permalink) { "some-permalink-1" }
    subject { clazz.new :permalink_field => permalink, :id => :some_id }

    context "without scope" do
      let(:scope) { nil }

      it "generates permalink with first free number" do
        scope1 = double()
        scope2 = double()
        clazz.should_receive(:where).with("id != ?", :some_id).and_return(scope1)
        scope1.should_receive(:where).with("permalink_field LIKE ?", "some-permalink%").and_return(scope2)
        scope2.should_receive(:map).and_return(["some-permalink", "some-permalink-1", "some-permalink-2"])

        subject.add_permalink_suffix

        subject.permalink_field.should be == 'some-permalink-3'
      end

      context "can generate permalink without index" do
        it "generates permalink with first free number" do
          scope1 = double()
          scope2 = double()
          clazz.should_receive(:where).with("id != ?", :some_id).and_return(scope1)
          scope1.should_receive(:where).with("permalink_field LIKE ?", "some-permalink%").and_return(scope2)
          scope2.should_receive(:map).and_return(["some-permalink-1", "some-permalink-2", "some-permalink-3"])

          subject.add_permalink_suffix

          subject.permalink_field.should be == 'some-permalink'
        end
      end
    end

    context "with scope" do
      let(:scope) { [:field_a, :field_b, :field_c] }

      it "generates permalink with first free number within scope" do
        subject.stub field_a: :value_a, field_b: :value_b, field_c: :value_c
        scope1, scope2, scope3 = double(), double(), double()
        clazz.should_receive(:where).with("id != ?", :some_id).and_return(scope1)
        scope1.should_receive(:where).with(field_a: :value_a, field_b: :value_b, field_c: :value_c).and_return(scope2)

        scope2.should_receive(:where).with("permalink_field LIKE ?", "some-permalink%").and_return(scope3)
        scope3.should_receive(:map).and_return(["some-permalink", "some-permalink-1", "some-permalink-2"])

        subject.add_permalink_suffix

        subject.permalink_field.should be == 'some-permalink-3'
      end
    end
  end
end
