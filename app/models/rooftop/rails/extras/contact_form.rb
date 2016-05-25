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

        def self.setup!
          (self.fields || DEFAULT_FIELDS).keys.each do |field|
            self.send(:attribute,field, {validate: true})
          end

          self.subject ||= "Contact form message"
          self.to ||= "change.me@#{self.to_s.underscore}"
          self.from ||= "change.me@#{self.to_s.underscore}"
          self.headers ||= {}
        end

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