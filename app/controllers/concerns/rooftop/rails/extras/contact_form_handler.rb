module Rooftop
  module Rails
    module Extras
      # A controller mixin to handle contact forms easily. If you don't use Page as your page class, you need to specify it.
      # You also need to specify the contact form class you're using (which needs to inherit from Rooftop::Rails::Extras::ContactForm)
      module ContactFormHandler
        extend ActiveSupport::Concern

        class_methods do
          def contact_form=(klass)
            @contact_form = klass
          end

          def contact_form
            @contact_form
          end

          def page_class=(klass)
            @page_class = klass
          end

          def page_class
            @page_class || ::Page
          end
        end

        def create
          raise ArgumentError, "You need to call contact_form=(YourClass) in your controller, which must inherit from Rooftop::Rails::Extras::ContactForm" unless self.class.contact_form.ancestors.include?(Rooftop::Rails::Extras::ContactForm)
          raise ArgumentError, "You need to include hidden fields for from_page and to_page IDs, so this controller can redirect appropriately" unless params.has_key?(:from_page) && params.has_key?(:to_page)
          form = self.class.contact_form.new(contact_form_params)
          if params.has_key?(:human_check) && params[:human_check].present?
            # the honeypot has been hit - raise an error
            raise ActionController::RoutingError, "you posted a human_check parameter, which is never supposed to be filled in (it's a honeypot)"
          end
          from_page, to_page = *self.class.page_class.where(post__in: [params[:from_page], params[:to_page]], orderby: :post__in)
          if form.deliver
            redirect_to Rooftop::Rails::RouteResolver.new(:page, to_page.nested_path).resolve
          else
            redirect_to Rooftop::Rails::RouteResolver.new(:page, from_page.nested_path).resolve(contact_form_params.merge(errors: form.errors.keys)), notice: form.errors.full_messages.to_sentence
          end
        end

        private
        def contact_form_params
          # Sometimes we might want to pass params into this which are arrays from e.g. checkboxes. So we allow the keys from the form as syms and also as hashes
          permitted_keys = [self.class.contact_form.fields.keys, self.class.contact_form.fields.keys.inject({}) {|h,k| h[k] = []; h }]
          self.class.contact_form.fields.keys
          params.require(self.class.contact_form.to_s.underscore.to_sym).permit(*permitted_keys)

        end
      end
    end
  end
end
