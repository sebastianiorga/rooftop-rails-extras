module Rooftop
  class ExtrasGenerator < ::Rails::Generators::Base
    desc "A wrapper around the common things we do with Rooftop and Rails. Creates a PagesController, Page model, sets up templates as we tend to "

    def create_page_class
      generate 'rooftop:page'
    end

    def install_pages_controller
      generate 'rooftop:pages_controller'
    end

    def create_content_page_template
      generate "rooftop:template content_page"
    end

    def create_homepage_template
      generate "rooftop:template homepage"
    end

    def create_post_class
      generate 'rooftop:post post'
    end
  end
end