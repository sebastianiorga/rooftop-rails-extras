module Rooftop
  class PostGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path("../templates", __FILE__)
    desc "Generate a post class - requires the name of the class to create"
    def create_class
      template 'post_class.rb.erb', "app/models/#{name}.rb"
    end
  end
end