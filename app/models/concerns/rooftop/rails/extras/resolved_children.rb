module Rooftop
  module Rails
    module Extras
      module ResolvedChildren
        extend ActiveSupport::Concern

        def resolved_children
          child_ids = children.collect(&:id)

          if child_ids.any?
            self.class.where(post__in: child_ids, orderby: :post__in)
          else
            []
          end

        end
      end

    end
  end
end