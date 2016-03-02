module Rooftop
  module Rails
    module Extras
      class Engine < ::Rails::Engine

        isolate_namespace Rooftop::Rails::Extras

        config.before_initialize do

        end

        initializer "add_helpers" do
          ActiveSupport.on_load(:action_view) do
            include Rooftop::Rails::Extras::NavigationHelper
          end
        end

        initializer "add_page_methods" do
          ::Rails.application.eager_load!
          Rooftop::Page.page_classes.each do |klass|
            klass.send(:include, Rooftop::Rails::Extras::PageRedirect)
          end
          Rooftop::Nested.nested_classes.each do |klass|
            klass.send(:include, Rooftop::Rails::Extras::ResolvedChildren)
          end
        end

      end
    end

  end
end
