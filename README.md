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