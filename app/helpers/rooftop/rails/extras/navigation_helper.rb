module Rooftop
  module Rails
    module Extras
      module NavigationHelper
        def subnavigation_for(entity, opts = {})
          default_opts = {
            class: 'subnavigation-list',
            current_class: 'is-current',
            current: nil
          }.merge(opts)
          raise ArgumentError, "#{entity.class} isn't a nested class" unless entity.respond_to?(:resolved_children)
          raise ArgumentError, "You passed a current #{entity.class.to_s.downcase} which isn't a #{entity.class} object" unless (default_opts[:current].nil? || default_opts[:current].is_a?(entity.class))
          if entity.resolved_children.any?
            # byebug
            content_tag(:ul, class: default_opts[:class]) do
              items = entity.resolved_children.collect do |child|
                subnavigation_item_for(child, default_opts)
              end
              items.join.html_safe
            end
          end
        end

        def menu_for(menu, opts={})
          default_opts = {
            class: 'main-navigation-list',
            current_class: 'is-current'
          }.merge(opts)
          content_tag(:ul, class: default_opts[:class]) do
            items = menu.items.collect do |item|
              menu_item_for(item, opts)
            end
            items.join.html_safe
          end
        end

        def menu_item_for(item, opts={})
          default_opts = {
            current_class: 'is-current'
          }.merge(opts)
          item_path = path_for_menu_item(item)
          item_class = path_matches?(item_path) ? default_opts[:current_class] : ""
          content_tag :li, class: item_class do
            link = content_tag :a, href: item_path do
              item.title.html_safe
            end
            child_links = ""
            if item.children.present?
              child_links = content_tag :ul do
                items = item.children.collect do |child|
                  menu_item_for(child, default_opts)
                end
                items.join.html_safe
              end
            end
            link + child_links
          end
        end

        def breadcrumbs_for(entity, opts = {})
          default_opts = {
            class: 'breadcrumbs',
            current_class: 'is-current'
          }.merge(opts)
          content_tag :ul, class: default_opts[:class] do
            items = entity.ancestors.reverse.inject({}) do |links,ancestor|
              links[(links.present? ?  "#{links.keys.last}/#{ancestor.slug}" : ancestor.slug)] = ancestor
              links
            end
            items.merge!({"#{items.keys.last}/#{entity.slug}" => entity})
            links = items.collect do |path, item|
              item_class = (item.id == entity.id ? default_opts[:current_class] : "")
              content_tag :li, class: item_class do
                content_tag :a, href: "/#{path}" do
                  item.title
                end
              end
            end
            links.join.html_safe
          end
        end

        private
        def subnavigation_item_for(entity, opts = {})
          list_opts = {}
          list_opts[:class] = opts[:current_class] if opts[:current].present? && opts[:current].id == entity.id
          # The link to the entity
          content_tag :li, list_opts do

            link = content_tag :a, href: "/#{entity.nested_path}" do
              entity.title.html_safe
            end

            child_links = ""

            # Nested ul for children if necessary
            if opts[:current].present? && (opts[:current].ancestors.collect(&:id).include?(entity.id) || opts[:current].id == entity.id)
              children = entity.class.where(post_parent: entity.id)
              if children.any?
                child_links = content_tag :ul do
                  items = children.collect do |child|
                    subnavigation_item_for(child, opts)
                  end
                  items.join.html_safe
                end
              end
            end
            link + child_links
          end
        end

      end
    end
  end
end