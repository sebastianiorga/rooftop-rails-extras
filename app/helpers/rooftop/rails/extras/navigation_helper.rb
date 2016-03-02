module Rooftop
  module Rails
    module Extras
      module NavigationHelper
        def subnavigation_for(entity, opts = {})
          raise ArgumentError, "#{entity.class} isn't a nested class" unless entity.respond_to?(:resolved_children)
          if entity.resolved_children.any?
            subnav = entity.resolved_children.collect do |child|
              subnavigation_item_for(child)
            end
            subnav.join
          end
        end

        private
        def subnavigation_item_for(entity, opts = {})
          content_tag :li do
            content_tag :a do
              entity.title
            end

          end
        end
      end
    end
  end
end