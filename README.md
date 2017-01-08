# Polymorph

Polymorph provides a dead simple interface for providing some limited functionality for polymorphic has_many :through relations. Why would we use this?

Say we have a schema like this:
```ruby
class Discussion
  has_many :comments
end

class Comment
  belongs_to :discussion
  belongs_to :participant, polymorphic: true
end

class User
  belongs_to :comment, as: :participant
end

class Robot
  belongs_to :comment, as: :participant
end
```

Sure would be cool here to call `discussion.participants`, and get back an `ActiveRecord::Relation` that we could play with, which had both Users and Robots in it. But, if we try this in rails:

```
ActiveRecord::HasManyThroughAssociationPolymorphicSourceError: Cannot have a has_many :through association
```
(ಠ_ಠ)

But with Polymorph, we can write a line of code like this:

```ruby
polymorph :participants, through: :comments, source_types: [:users, :robots], fields: [:id, :name]
```

And get a polymorphic `ActiveRecord::Relation` back:

```
#<ActiveRecord::AssociationRelation [
  #<User  id: 1, name: "Fry">,
  #<User  id: 2, name: "Leela">,
  #<Robot id: 1, name: "Bender">
]>
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-polymorph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polymorph

## Usage

Polymorph does one thing and one thing only, and that is define the `polymorph` method on `ActiveRecord::Base`.

Available options:

- **through**:      (required) The name of the relation you'd like to construct
- **source_types**: (required) A list of classes that could be returned by this polymorphic relationship
- **fields**:       (optional, default: [:id]) A list of fields the polymorphic classes have in common (these are also the fields which you can do 'where' queries on)
- **through_class**: (optional) The name of the class the relationship reaches through. Is inferred by `through` by default.
- **source_column**: (optional) The name of the polymorphic association columns (ie, this is the 'participant' in `participant_type` and `participant_id`). Inferred from the relation name by default.

So, as a default, we could write
```ruby
polymorph :participants, through: :comments, source_types: [:users, :robots]
```

Which would work perfectly if we're reaching for Users and Robots through Comments, and Users and Robots don't share any field names.

If Users and Robots share a 'name' field, we write:

```ruby
polymorph :participants, through: :comments, source_types: [:users, :robots], fields: [:id, :name]
```

If we want to call these 'participants', but our database columns are already set to 'commenter_id' and 'commenter_type', we can invoke the `source_column` method:

```ruby
polymorph :commenters, through: :comments, source_types: [:users, :robots], source_column: :commenter
```

If the ruby class cannot be inferred by the 'through' option, we can point it to the right place with `through_class`:

```ruby
polymorph :commenters, through: :comments, source_types: [:users, :robots], through_class: Comments::Base
```

NB that this relation has somewhat limited support for further querying! Currently, we support count, pluck, and simple where clauses on common keys:

```
discussion.participants.count # => 3
discussion.participants.pluck(:name) # => ["Fry, Leela", "Bender"]
discussion.participants.where(name: "Bender") # => #<ActiveRecord::Relation [ #<Robot id: 1, name: "Bender" ]>
```

Using additional things like joins or where clauses for columns that aren't shared by the source tables will probably end in pain. I am open to extending this in the future, but it works for what I need it for for now. :D

I built this so that I could use it in [Loomio](https://github.com/loomio/loomio). Please use it if you think it's helpful; and I'm happy to hear about any troubles you come across.

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gdpelican/activerecord-polymorph. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
