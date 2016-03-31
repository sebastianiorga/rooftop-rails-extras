module Rooftop
  module Rails
    module Extras
      class ContactForm < MailForm::Base
        class << self
          attr_accessor :fields, :subject, :to, :from, :headers
        end

        DEFAULT_FIELDS = {
          name: :text_field,
          email: :text_field,
          message: :text_area
        }

        def self.inherited(base)
          (base.fields || DEFAULT_FIELDS).keys.each do |field|
            base.send(:attribute,field, {validate: true})
          end

          base.subject ||= "Contact form message"
          base.to ||= "change.me@#{base.to_s.underscore}"
          base.from ||= "change.me@#{base.to_s.underscore}"
          base.headers ||= {}
        end
        #
        # attribute :salutation
        # attribute :first_name,      validate: true
        # attribute :last_name,     validate: true
        # attribute :email, validate: true
        # attribute :phone
        # attribute :message, validate: true
        # attribute :nickname,  captcha: true

        # Declare the e-mail headers. It accepts anything the mail method
        # in ActionMailer accepts.
        def headers
          {
            subject: self.class.subject,
            to: self.class.to,
            from: %("Contact form" <#{self.class.from}>)
          }.merge(self.class.headers)
        end

        def fields
          self.class.fields
        end

      end
    end
  end
end