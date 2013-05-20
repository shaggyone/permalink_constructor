# -*- encoding : utf-8 -*-

shared_examples_for "filters permalink" do |permalink_field|
  permalink_field ||= :permalink

  it { should filter_field_value(permalink_field).from("/this is a//long  page-path/").to('this-is-a/long--page-path') }
  it { should filter_field_value(permalink_field).from("/").to('/') }
end

shared_examples_for "constructs permalink" do |field_name, options|
  options ||= {}
  options.reverse_merge! :permalink_field => :permalink
  permalink_field = options[:permalink_field]

  it { should construct_permalink.from(field_name).to(permalink_field) }
  it { should construct_permalink.from(field_name, "привет, как дела? что намечается?").to(permalink_field, 'privet-kak-dela-chto-namechaetsya') }
  it { should construct_permalink.from(field_name, "privet, kak dela? chto namechaetsya?").to(permalink_field, 'privet-kak-dela-chto-namechaetsya') }
  it { should_not construct_permalink.from(field_name).when_permalink_given }

end

Rspec::Matchers.define :filter_field_value do |field_name|
  chain :from do |value|
    @from_value = value
  end

  chain :to do |value|
    @to_value = value
  end

  match do |model|
    model.send "#{field_name}=", @from_value
    model.valid?

    model.send(field_name) == @to_value
  end

  failure_message_for_should do |actual|
    "expected #{actual.class} to filter #{@field_name} from '#{@from_value}' to '#{@to_value}'"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.class} not to filter #{@field_name} from '#{@from_value}' to '#{@to_value}'"
  end
end

Rspec::Matchers.define :construct_permalink do
  chain :from do |field_name, field_value|
    @field_name  = field_name
    @field_value = field_value
  end

  chain :to do |permalink_field, permalink_value|
    @permalink_field = permalink_field
    @permalink_value = permalink_value
  end

  chain :when_permalink_given do
    @permalink_given = true
  end

  match do |model|
    @field_name ||= :name
    @field_value ||= "вот он, большой и сложный заголовок"
    @permalink_field ||= :permalink
    @permalink_value ||= 'vot-on-bolshoy-i-slozhnyy-zagolovok'
    model.stub!(@field_name).and_return(@field_value)
    model.send "#{@permalink_field}=", nil unless @permalink_given
    model.valid?

    model.send(@permalink_field) == @permalink_value
  end

  failure_message_for_should do |actual|
    "expected #{actual.class} to construct #{@permalink_field}='#{@permalink_value}' from #{@field_name}='#{@field_value}'#{ @permalink_given ? ' when permalink given' : '' }"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.class} not to construct #{@permalink_field}='#{@permalink_value}' from #{@field_name}='#{@field_value}'#{ @permalink_given ? ' when permalink given' : '' }"
  end
end

