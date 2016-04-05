module Rooftop
    class PagesControllerGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      desc "Generate a standardised PagesController and views. Assumes a PageDecorator and Page model"

      def copy_template
        template "pages_controller.rb.erb", "app/controllers/pages_controller.rb"
      end

      def create_views
        template "application.html.erb", "app/views/layouts/application.html.erb"
        template "show.html.erb", "app/views/pages/show.html.erb"
        template "index.html.erb", "app/views/pages/index.html.erb"
      end

      def add_route
        comment_lines 'config/routes.rb', /pages#.*/
        route 'root to: "pages#index"'
        route 'match "/*nested_path", via: [:get], to: "pages#show", as: :page'
        inject_into_file 'config/routes.rb', before: 'match "/*nested_path"' do <<-'RUBY'
        # IMPORTANT: this is a greedy catchall route - it needs to be the last route in the file.
        RUBY
        end
      end

    end
end