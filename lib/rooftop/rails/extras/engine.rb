module Rooftop
  module Rails
    module Extras
      class Engine < ::Rails::Engine

        isolate_namespace Rooftop::Rails::Extras

        config.before_initialize do
          # ::Rails.application.eager_load!
          Rooftop::Page.extra_includes ||= []
          Rooftop::Page.extra_includes << Rooftop::Rails::Extras::PageRedirect

          Rooftop::Nested.extra_includes ||= []
          Rooftop::Nested.extra_includes << Rooftop::Rails::Extras::ResolvedChildren

        end

        initializer "add_helpers" do
          ActiveSupport.on_load(:action_view) do
            include Rooftop::Rails::Extras::NavigationHelper
            include Rooftop::Rails::Extras::RelatedFieldsHelper

          end
        end

       config.to_prepare do

        end

      end
    end

  end
end
