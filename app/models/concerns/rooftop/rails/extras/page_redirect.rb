module Rooftop
  module Rails
    module Extras
      module PageRedirect
        extend ActiveSupport::Concern

        def redirect?
          fields.respond_to?(:redirect_this_page) && fields.redirect_this_page == true && fields.respond_to?(:redirect_url) && fields.redirect_url.present?
        end

        def redirect_to
          if redirect?
            fields.redirect_url
          end
        end

      end
    end
  end
end