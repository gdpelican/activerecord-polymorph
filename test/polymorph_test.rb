require 'test_helper'

class PolymorphTest < Minitest::Test
  extend Minitest::Spec::DSL

  let(:discussion) { Discussion.create }
  let(:fry)    { User.create(name: "Fry") }
  let(:leela)  { User.create(name: "Leela") }
  let(:bender) { Robot.create(name: "Bender") }
  let(:comment1) { Comment.create(participant: fry, discussion: discussion) }
  let(:comment2) { Comment.create(participant: leela, discussion: discussion) }
  let(:comment3) { Comment.create(participant: bender, discussion: discussion) }
  let(:participants) { discussion.participants }
  let(:commenters) { discussion.commenters }

  def test_that_it_has_a_version_number
    refute_nil ::Polymorph::VERSION
  end

  def test_it_creates_a_polymorphic_through
    setup_polymorph_default
    comment1; comment2; comment3

    assert_includes participants, fry
    assert_includes participants, leela
    assert_includes participants, bender
  end

  def test_it_can_count
    setup_polymorph_default
    comment1; comment2; comment3

    assert_equal 3, participants.count
  end

  def test_it_respects_source_types
    setup_polymorph_users_only
    comment1; comment2; comment3

    assert_includes participants, fry
    assert_includes participants, leela
    refute_includes participants, bender
  end

  def test_it_can_pluck
    setup_polymorph_fields
    comment1; comment2; comment3

    assert_includes participants.pluck(:name), "Fry"
    assert_includes participants.pluck(:name), "Leela"
    assert_includes participants.pluck(:name), "Bender"
  end

  def test_it_can_where
    setup_polymorph_fields
    comment1; comment2; comment3

    filtered = participants.where(name: "Bender")
    refute_includes filtered, fry
    refute_includes filtered, leela
    assert_includes filtered, bender
  end

  def test_it_respects_source_column
    setup_polymorph_source_column
    comment1; comment2; comment3

    assert_includes commenters, fry
    assert_includes commenters, leela
    assert_includes commenters, bender
  end
end
