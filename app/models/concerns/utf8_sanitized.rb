require 'active_support/concern'

module Utf8Sanitized  
  extend ActiveSupport::Concern

  UNICODE_FIELDS = [:content]

  included do
    UNICODE_FIELDS.each do |field|
      define_method "#{field}=" do |value|
        super value.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end
    end
  end
  
end