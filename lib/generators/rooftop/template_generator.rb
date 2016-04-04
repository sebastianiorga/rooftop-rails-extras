module Rooftop
  class TemplateGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path("../templates", __FILE__)
    desc "Generate a template in views/layouts/templates"
    def copy_template
      template "template.html.erb", "app/views/layouts/templates/#{name}.html.erb"
    end
  end
end