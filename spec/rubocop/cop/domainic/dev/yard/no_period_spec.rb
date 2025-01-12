# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'

RSpec.describe RuboCop::Cop::Domainic::Dev::YARD::NoPeriod do
  include RuboCop::RSpec::ExpectOffense

  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'is expected to register an offense for lines ending with periods' do
    expect_offense(<<~RUBY)
      # This is a description.
      ^^^^^^^^^^^^^^^^^^^^^^^^ YARD/NoPeriod: YARD docstring lines should not end with periods
      # More details about it.
      ^^^^^^^^^^^^^^^^^^^^^^^^ YARD/NoPeriod: YARD docstring lines should not end with periods
      class MyClass; end
    RUBY

    expect_correction(<<~RUBY)
      # This is a description
      # More details about it
      class MyClass; end
    RUBY
  end

  it 'is expected not to register an offense for lines without periods' do
    expect_no_offenses(<<~RUBY)
      # This is a description
      # More details about it
      class MyClass; end
    RUBY
  end

  it 'is expected not to register an offense for ellipsis' do
    expect_no_offenses(<<~RUBY)
      # This continues on...
      # And has more...
      class MyClass; end
    RUBY
  end

  it 'is expected not to register an offense for code examples' do
    expect_no_offenses(<<~RUBY)
      # A description
      #
      # @example
      #   my_obj.chain.call.
      #   something.other
      class MyClass; end
    RUBY
  end

  it 'is expected not to register an offense for code blocks' do
    expect_no_offenses(<<~RUBY)
      # A description
      #
      # ```ruby
      #   my_obj.chain.call.
      #   something.other
      # ```
      class MyClass; end
    RUBY
  end

  it 'is expected not to register an offense for empty lines' do
    expect_no_offenses(<<~RUBY)
      # A description
      #
      # More info
      class MyClass; end
    RUBY
  end

  context 'with method definitions' do
    it 'is expected to register an offense for periods in method documentation' do
      expect_offense(<<~RUBY)
        # This method does something.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ YARD/NoPeriod: YARD docstring lines should not end with periods
        def foo; end
      RUBY

      expect_correction(<<~RUBY)
        # This method does something
        def foo; end
      RUBY
    end
  end

  context 'with comment breaks' do
    it 'is expected to only check the last consecutive comment block' do
      expect_offense(<<~RUBY)
        # Random comment.

        # This is documentation.
        ^^^^^^^^^^^^^^^^^^^^^^^^ YARD/NoPeriod: YARD docstring lines should not end with periods
        def foo; end
      RUBY

      expect_correction(<<~RUBY)
        # Random comment.

        # This is documentation
        def foo; end
      RUBY
    end
  end
end
