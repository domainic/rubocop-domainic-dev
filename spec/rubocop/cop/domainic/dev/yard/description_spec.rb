# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'

RSpec.describe RuboCop::Cop::Domainic::Dev::YARD::Description do
  include RuboCop::RSpec::ExpectOffense

  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'with attribute definitions' do
    it 'is expected to register an offense when docstring starts with a tag' do
      expect_offense(<<~RUBY)
        # @api private
        attr_accessor :foo
        ^^^^^^^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
        # @api private
        attr_reader :bar
        ^^^^^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
        # @api private
        attr_writer :baz
        ^^^^^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
      RUBY
    end

    it 'is expected to register an offense when description has no blank line before tags' do
      expect_offense(<<~RUBY)
        # An attribute
        # @api private
        attr_accessor :foo
        ^^^^^^^^^^^^^^^^^^ YARD/Description: Missing blank line between description and YARD tags
      RUBY

      expect_correction(<<~RUBY)
        # An attribute
        #
        # @api private
        attr_accessor :foo
      RUBY
    end

    it 'is expected not to register an offense with correct formatting' do
      expect_no_offenses(<<~RUBY)
        # An attribute
        #
        # @api private
        attr_accessor :foo
      RUBY
    end
  end

  context 'with method definitions' do
    it 'is expected to register an offense when docstring starts with a tag' do
      expect_offense(<<~RUBY)
        # @api private
        def foo; end
        ^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
      RUBY
    end

    it 'is expected to register an offense when description has no blank line before tags' do
      expect_offense(<<~RUBY)
        # This method does something.
        # @api private
        def foo; end
        ^^^^^^^^^^^^ YARD/Description: Missing blank line between description and YARD tags
      RUBY

      expect_correction(<<~RUBY)
        # This method does something.
        #
        # @api private
        def foo; end
      RUBY
    end

    it 'is expected not to register an offense with correct formatting' do
      expect_no_offenses(<<~RUBY)
        # This method does something.
        #
        # @api private
        def foo; end
      RUBY
    end
  end

  context 'with classes' do
    it 'is expected to register an offense when docstring starts with a tag' do
      expect_offense(<<~RUBY)
        # @author John Doe
        class Foo; end
        ^^^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
      RUBY
    end

    it 'is expected to register an offense when description has no blank line before tags' do
      expect_offense(<<~RUBY)
        # A useful class.
        # @author John Doe
        class Foo; end
        ^^^^^^^^^^^^^^ YARD/Description: Missing blank line between description and YARD tags
      RUBY

      expect_correction(<<~RUBY)
        # A useful class.
        #
        # @author John Doe
        class Foo; end
      RUBY
    end

    it 'is expected not to register an offense with correct formatting' do
      expect_no_offenses(<<~RUBY)
        # A useful class.
        #
        # @author John Doe
        class Foo; end
      RUBY
    end
  end

  context 'with modules' do
    it 'is expected to register an offense when docstring starts with a tag' do
      expect_offense(<<~RUBY)
        # @since 1.0.0
        module Foo; end
        ^^^^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
      RUBY
    end

    it 'is expected to register an offense when description has no blank line before tags' do
      expect_offense(<<~RUBY)
        # Module containing useful functionality.
        # @since 1.0.0
        module Foo; end
        ^^^^^^^^^^^^^^^ YARD/Description: Missing blank line between description and YARD tags
      RUBY

      expect_correction(<<~RUBY)
        # Module containing useful functionality.
        #
        # @since 1.0.0
        module Foo; end
      RUBY
    end

    it 'is expected not to register an offense with correct formatting' do
      expect_no_offenses(<<~RUBY)
        # Module containing useful functionality.
        #
        # @since 1.0.0
        module Foo; end
      RUBY
    end
  end

  context 'with constants' do
    it 'is expected to register an offense when docstring starts with a tag' do
      expect_offense(<<~RUBY)
        # @api private
        CONSTANT = 'value'
        ^^^^^^^^^^^^^^^^^^ YARD/Description: Missing description in YARD docstring. The first line should be descriptive text
      RUBY
    end

    it 'is expected to register an offense when description has no blank line before tags' do
      expect_offense(<<~RUBY)
        # A meaningful constant.
        # @api private
        CONSTANT = 'value'
        ^^^^^^^^^^^^^^^^^^ YARD/Description: Missing blank line between description and YARD tags
      RUBY

      expect_correction(<<~RUBY)
        # A meaningful constant.
        #
        # @api private
        CONSTANT = 'value'
      RUBY
    end

    it 'is expected not to register an offense with correct formatting' do
      expect_no_offenses(<<~RUBY)
        # A meaningful constant.
        #
        # @api private
        CONSTANT = 'value'
      RUBY
    end
  end

  context 'with no docstring' do
    it 'is expected not to register an offense' do
      expect_no_offenses(<<~RUBY)
        def foo; end
      RUBY
    end
  end

  context 'with empty docstring' do
    it 'is expected not to register an offense' do
      expect_no_offenses(<<~RUBY)
        #
        def foo; end
      RUBY
    end
  end

  context 'with multi-line descriptions' do
    it 'is expected to register an offense when no blank line after multi-line description' do
      expect_offense(<<~RUBY)
        # This is a more verbose description Lorem ipsum dolor sit amet, consectetur
        # adipiscing elit. Nullam ac aliquet turpis. Maecenas vulputate suscipit nibh.
        # @api private
        def foo; end
        ^^^^^^^^^^^^ YARD/Description: Missing blank line between description and YARD tags
      RUBY

      expect_correction(<<~RUBY)
        # This is a more verbose description Lorem ipsum dolor sit amet, consectetur
        # adipiscing elit. Nullam ac aliquet turpis. Maecenas vulputate suscipit nibh.
        #
        # @api private
        def foo; end
      RUBY
    end

    it 'is expected not to register an offense with correct multi-line formatting' do
      expect_no_offenses(<<~RUBY)
        # This is a more verbose description Lorem ipsum dolor sit amet, consectetur
        # adipiscing elit. Nullam ac aliquet turpis. Maecenas vulputate suscipit nibh.
        #
        # @api private
        def foo; end
      RUBY
    end
  end
end
