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

Then doing a search is as simple as:

```
   SomePostType.search("your string") #will return a collection of matching objects.
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
    self.setup! #you need to call setup! here because there's no elegant way to call it automatically in the parent class.
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
    <!-- This tag can be included if you want, it's a honeypot so make sure you leave it empty -->
    <%= text_field_tag :human_check, "", class: "somethinghidden" %>

    <p><input type="submit" id="submit" value="Send" /></p>
<% end %>
```

### Handling Errors
`Rooftop::Rails::Extras::ContactForm` assumes every field you enter is required. If there are errors on the model, the controller will return the user to the original page (as a redirect) but add some querystring params:

* `errors[]` - an array of each fieldname with errors (in our example above, we check for this and add a classname on the offending inputs
* params for each entered field, so you can set the field values to save data re-entry

## Navigation View Helpers
For nested post types (pages, products etc.) you might well want to create subnavigation, showing the path to this page, its siblings and parent pages. We use this often enough at [Error Agency](http://error.agency) to have a helper do the iteration.

We also generally use WordPress menus in Rooftop for the main navigation on a site, and also footer links.

### `subnavigation_for()` helper
Given a page, this helper will return a nested unordered list of links, starting at the root of the page, and rendering the page, it's parents and their siblings, and its ancestors above parents.

Here's a call to the helper in a view, with the default options shown:

```
<%# @page is defined in your controller as a call to Page.find() %>
<%= subnavigation_for(@page, class: 'subnavigation-list', current_class: 'is-current', current: nil) %>
```

If you want to specify different class names for the UL and currently-active page, just amend the options.

If you want to highlight *another page* when the subnav is rendered, that's fine too:

```
<%= subnavigation_for(@page, current: @another_page) %>
```

You might want to do this if, for example, your markup requires some navigational components in 2 different places.

### `menu_for()` helper
Given a `Rooftop::Menus::Menu` object, `menu_for()` will return a nested unordered list.

```
<%# @menu is defined in your controller as a call to Rooftop::Menus::Menu.find()
<%= menu_for(@menu, current_class: 'is-current') %>
```

A utility `menu-level-[x]` class is added to each level of the nested menu, in case you want to target a particular level in a different way with css. Useful for dropdown menus.

### `breadcrumbs_for()` helper
Breadcrumbs are similar to a nested subnavigation, but they only represent a direct path to this page (or other nested post type).

```
<%# @page is defined in your controller as a call to Page.find() %>
<%= breadcrumbs_for(@page, class: 'breadcrumbs', current_class: 'is-current') %>
```

# Licence
This gem is licenced GPLv3; contributions are most welcome!

# Contributing
The usual: fork, change, PR. Clean PRs (rebased if necessary) are preferred, but anything you can do is valuable.