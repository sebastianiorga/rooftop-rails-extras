module Rooftop
  module Rails
    module Extras
      module RelatedFieldsHelper
        def field_from_related_resource(resource, field)
          field_data = resource[:advanced].select {|f| f[:fields].collect {|f| f[:name] == field.to_s}.any?}
          if field_data.any?
            field_data.first[:fields].find {|f| f[:name] == field.to_s}.try(:[],:value)
          end
        end
      end
    end
  end
end