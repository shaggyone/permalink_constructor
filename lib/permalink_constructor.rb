require "permalink_constructor/version"
require "active_support/concern"

module PermalinkConstructor
  extend ActiveSupport::Concern

  def generate_permalink
    permalink = send(self.class.permalink_field_name)
    if permalink.blank?
      field_value = send(self.class.permalink_source_field_name)

      permalink = field_value
    end

    self.send "#{self.class.permalink_field_name}=", filter_permalink(permalink)
  end

  def add_permalink_suffix
    scope = self.class
    scope = scope.where("id != ?", id) unless new_record?

    attrs_scope = Array.wrap(self.class.permalink_options[:scope]).inject({}) do |v, field_name|
      v[field_name] = self.send(field_name)
      v
    end

    scope = scope.where(attrs_scope) if attrs_scope.any?

    permalink = send(self.class.permalink_field_name)
    permalink_without_suffix = permalink.gsub(/-\d+$/, '')
    synonymous_permalinks = scope.where("#{ self.class.permalink_field_name } LIKE ?", "#{ permalink_without_suffix}%" ).map(&:permalink)

    n = 0
    while synonymous_permalinks.include?(permalink)
      if n.zero?
        permalink = permalink_without_suffix
      else
        permalink = "#{permalink_without_suffix}-#{n}"
      end

      n = n + 1
    end
    self.send "#{self.class.permalink_field_name}=", filter_permalink(permalink)
  end

  def filter_permalink(permalink)
    if permalink.present?
      unless permalink == '/'
        permalink = Russian.transliterate(permalink).downcase.gsub(/\s/, '-').gsub(/[^#{self.class.permalink_options[:allowed_chars]}]/, '') \
          .sub(/^\/+/, '').sub(/\/+$/, '').gsub(/\/+/, '/')
      end
    end
    permalink
  end

  module ClassMethods
    def constructs_permalink_from field_name, options = {}
      options.reverse_merge! :permalink_field => :permalink,
                             :allowed_chars   => "_a-z0-9\/\-",
                             :validate_uniqueness => true

      options.merge! :title_field => field_name

      permalink_field = options[:permalink_field]

      validation_options = { :format => { :with => /^[#{options[:allowed_chars]}]+$/ } }
      validation_options[:presence]   = {} if options[:validate_presence]

      if options[:validate_uniqueness]
        validation_options[:uniqueness] = { scope: options[:scope] }
      end

      validates permalink_field, validation_options

      define_singleton_method :permalink_options do
        options
      end

      define_singleton_method :permalink_source_field_name do
        field_name
      end

      define_singleton_method :permalink_field_name do
        permalink_field
      end

      before_validation :generate_permalink
      before_validation :add_permalink_suffix if options[:increment]
    end
  end
end
