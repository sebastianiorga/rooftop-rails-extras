module Rooftop
  class PageGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    desc "Generate a page class, mixing in Rooftop::Page and Rooftop::Rails::Extras::ResourceSearch"
    class_option :class_name, :type => :string, :desc => "The class name to generate", :default => "page"
    def create_class
      template 'page_class.rb.erb', 'app/models/page.rb'
    end

    def create_decorator
      generate "decorator #{options[:class_name]}"
    end
  end
end