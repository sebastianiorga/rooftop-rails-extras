module Rooftop
  module Rails
    module Extras
      # A module to search for free text in a resource. You can add extra fields to search the free text in, by specifying a proc to call (which should return the text you want to search)
      module ResourceSearch
        extend ActiveSupport::Concern

        included do
          scope :search, ->(q) {
            all.to_a.select do |item|
              q = q.gsub(/[^a-zA-z1-9 ]/,"")
              item.searchable_text.match(%r{#{q.downcase}})
            end
          }
        end

        class_methods do

          # A method which takes a lambda which is expected to return a string of text for searching.
          def add_search_field(field)
            @search_fields ||= []
            @search_fields << field
          end
          # A collection of lambdas, each of which returns a string
          def search_fields
            @search_fields ||= []
          end
        end

        def searchable_text
          remove_regex = /[^a-zA-z1-9 ]/
          text = []
          text << title.gsub(remove_regex,"").downcase
          text << ActionController::Base.helpers.strip_tags(fields.content).gsub(remove_regex,"").downcase
          # Iterate over the search field lambdas, and call each one, passing in self. Check the arity is 1, to ensure that the lambda is expecting the object
          self.class.search_fields.each do |field|
            if field.arity == 1
              text << ActionController::Base.helpers.strip_tags(field.call(self)).gsub(remove_regex,"").downcase
            end
          end
          text.join(" ")

        end

      end
    end
  end
end