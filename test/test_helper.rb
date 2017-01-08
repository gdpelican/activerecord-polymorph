$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'
require 'active_record'
require 'temping'
require 'polymorph'
require 'byebug'

ActiveRecord::Base.establish_connection adapter: :sqlite3, database: ':memory:'

def setup_polymorphic_association
  return if Object.const_defined?("Discussion")
  Temping.create :discussion do
    has_many :comments
  end

  Temping.create :comment do
    belongs_to :discussion
    belongs_to :participant, polymorphic: true

    with_columns do |t|
      t.integer :discussion_id
      t.integer :participant_id
      t.string :participant_type
    end
  end

  Temping.create :user do
    has_many :comments, as: :participant
    with_columns do |t|
      t.string :name
    end
  end

  Temping.create :robot do
    has_many :comments, as: :participant
    with_columns do |t|
      t.string :name
    end
  end
end

def setup_polymorph_default
  setup_polymorphic_association
  Discussion.class_eval "polymorph :participants, through: :comments, source_types: [:users, :robots]"
end

def setup_polymorph_users_only
  setup_polymorphic_association
  Discussion.class_eval "polymorph :participants, through: :comments, source_types: [:users]"
end

def setup_polymorph_fields
  setup_polymorphic_association
  Discussion.class_eval "polymorph :participants, through: :comments, source_types: [:users, :robots], fields: [:id, :name]"
end

def setup_polymorph_source_column
  setup_polymorphic_association
  Discussion.class_eval "polymorph :commenters, through: :comments, source_types: [:users, :robots], source_column: :participant"
end
