# Rooftop::Rails::Extras
A selection of things we're finding handy at [Error](http://error.agency) so you might, too.

## `Rooftop::Rails::Extras::ResourceSearch` - Free-text Searchable resources
Rooftop CMS search is a work in progress, and only supports basic WordPress LIKE queries at the moment. You can do a little better than that, at the expense of getting a collection of all resources, if you do a regex match in Rails.
 
```
class SomePostType
    include Rooftop::Post
    include Rooftop::Rails::Extras::ResourceSearch #searches title and content by default
    
    # add extra fields to search, by creating a lambda which returns text. Markup and punctuation is stripped after calling it.
    add_search_field ->(record) {
        record.fields.some_custom_field
    }
    
    # Or a more complicated example, where a custom field is returning an object of some sort
    add_search_field ->(record) {
        record.fields.some_complex_object[:some][:deep][:data]
    }
    
    # or even a collection, from an ACF repeater
    add_search_field ->(record) {
        content = record.fields.some_repeater.collect do |object|
            object.some.deep.thing
        end
        content.join(" ") #return the collection, joined with a space
    }
    
end
```

## Contact form handling
Almost every website we build needs a simple mail handler. Extending the [mail_form gem](https://github.com/plataformatec/mail_form), we've added a way to handle these with minimal fuss. Some assumptions are made in the name of expedience; if you need more than this, you probably need to use `mail_form` directly.

### Create a contact form model, inheriting from the Rooftop extras one
First define a model which inherits from `Rooftop::Rails::Extras::ContactForm`. You need to do some setup in here, including:

* Defining the fields (and types) you need to handle
* The to / from addresses, and any extra headers you want to define in the email

```
class ContactForm < Rooftop::Rails::Extras::ContactForm #you can call your class anything
    #the values of these hashes are Rails form helper method names
    self.fields = {
        name: :text_field, 
        email: :text_field,
        message: :text_area
    }
    self.to = "the email you want to send the contact messages to"
    self.from = "the email from which you want to send the messages"
end
```

### Create a controller and add the mixin
Write a simple controller and add the `Rooftop::Rails::Extras::ContactFormHandler` mixin.

```
class ContactFormsController < ApplicationController # you can call your controller anything to suit
  include Rooftop::Rails::Extras::ContactFormHandler
  # Declare the class you've just defined, above. If you called it something else, change it here.
  self.contact_form = ::ContactForm
end
```

### Create a route
If you called your controller something else, you need to tweak the route accordingly. Of course, this is all just normal Rails routes so you can do what you need to, as long as a POST request hits your controller.

```
resources :contact_forms, only: :create
```

### Define a 'thankyou' page in Rooftop CMS
When the form is submitted, the controller redirects the user to a thankyou page, which is any page you want. You need to derive the ID of this page somehow, to get it into a hidden field in the form. Generally, we create a field in Rooftop for this, and decorate the Page model with a'thankyou_page_id' method which returns the ID. 

### Create your form
How you build the form is up to you, but here's a quick way to use the fields you defined above.

```
<%= form_for ContactForm.new, method: :post, class: 'contact' do |f| %>
<!-- The form will create a flash with the errors from the form, if any -->
    <% if flash[:notice].present?  %>
        <p class="form-errors">
            Your message couldn't be sent: <%= flash[:notice] %>
        </p>
    <% end %>
    <!-- f.object is the ContactForm instance above, so we know it responds to `fields` -->
    <% f.object.fields.each do |field, type| %>
    <!-- iterate over each field, setting the value if passed in, and adding an error class if there's an error on the field -->
        <p>
            <%= f.label field %>
            <%= f.send(
                    type,
                    field,
                    class: (params[:errors].present? && params[:errors].include?(field.to_s)) ? "has-errors" : "",
                    value: params[field],
                    required: true
                )%>
        </p>
    <% end %>
    <!-- these hidden tags tell the controller how to redirect the user. If there's an error, we'll redirect back to this page, with get params for the errors and each completed field. If there isn't, the user is redirected to the thankyou page -->
    <%= hidden_field_tag :from_page, page.id %>
    <%= hidden_field_tag :to_page, page.thankyou_page_id %>

    <p><input type="submit" id="submit" value="Send" /></p>
<% end %>
```

### Handling Errors
`Rooftop::Rails::Extras::ContactForm` assumes every field you enter is required. If there are errors on the model, the controller will return the user to the original page (as a redirect) but add some querystring params:

* `errors[]` - an array of each fieldname with errors (in our example above, we check for this and add a classname on the offending inputs
* params for each entered field, so you can set the field values to save data re-entry
