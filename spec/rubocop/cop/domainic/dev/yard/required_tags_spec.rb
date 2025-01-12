# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'

RSpec.describe RuboCop::Cop::Domainic::Dev::YARD::RequiredTags do
  include RuboCop::RSpec::ExpectOffense

  describe '.cop_name' do
    subject(:cop_name) { described_class.cop_name }

    it { is_expected.to match 'YARD/RequiredTags' }
  end

  describe 'offenses' do
    subject(:cop) { described_class.new(config) }

    let(:config) do
      RuboCop::Config.new(
        'YARD/RequiredTags' => {
          'RequireExampleOnPublicMethods' => true,
          'RequireParams' => true,
          'RequireRaise' => true,
          'RequireYield' => true,
          'RequiredTags' => {
            'Attribute' => %w[api author return since],
            'Class' => %w[api author since],
            'Constant' => %w[api author return since],
            'Method' => %w[api author return since],
            'Module' => %w[api author since]
          }
        }
      )
    end

    context 'when checking attributes' do
      it 'is expected to register an offense for missing required tags' do
        expect_offense(<<~RUBY)
          # Missing tags comment
          attr_accessor :my_accessor
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @return, @since

          # Missing tags comment
          attr_reader :my_reader
          ^^^^^^^^^^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @return, @since

          # Missing tags comment
          attr_writer :my_writer
          ^^^^^^^^^^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @return, @since
        RUBY
      end

      it 'is expected not to register an offense when all required tags are present' do
        expect_no_offenses(<<~RUBY)
          # @api public
          # @author John Smith
          # @since 0.2.0
          # @return [String]
          attr_accessor :my_accessor

          # @api public
          # @author John Smith
          # @since 0.2.0
          # @return [String]
          attr_reader :my_reader

          # @api public
          # @author John Smith
          # @since 0.2.0
          # @return [String]
          attr_writer :my_writer
        RUBY
      end
    end

    context 'when checking classes' do
      it 'is expected to register an offense for missing required tags' do
        expect_offense(<<~RUBY)
          # Missing tags comment
          class MyClass
          ^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @since
          end
        RUBY
      end

      it 'is expected not to register an offense when all required tags are present' do
        expect_no_offenses(<<~RUBY)
          # @api public
          # @author John Smith
          # @since 1.0.0
          class MyClass
          end
        RUBY
      end
    end

    context 'when checking methods' do
      it 'is expected to register an offense for missing required tags' do
        expect_offense(<<~RUBY)
          # Missing tags comment
          def my_method(param1)
          ^^^^^^^^^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @return, @since
            puts param1
          end
        RUBY
      end

      it 'is expected to register an offense for missing @raise tag when method raises' do
        expect_offense(<<~RUBY)
          # @api private
          # @author John Smith
          # @return [void]
          # @since 1.0.0
          def my_method
          ^^^^^^^^^^^^^ Missing required YARD tag(s): @raise
            raise StandardError
          end
        RUBY
      end

      it 'is expected to register an offense for missing @yield tag when method yields' do
        expect_offense(<<~RUBY)
          # @api private
          # @author John Smith
          # @return [void]
          # @since 1.0.0
          def my_method
          ^^^^^^^^^^^^^ Missing required YARD tag(s): @yield
            yield
          end
        RUBY
      end

      it 'is expected to register an offense for missing @example tag on public methods' do
        expect_offense(<<~RUBY)
          # @api public
          # @author John Smith
          # @return [void]
          # @since 1.0.0
          def my_method
          ^^^^^^^^^^^^^ Missing required YARD tag(s): @example
          end
        RUBY
      end

      it 'is expected not to register an offense when all required tags are present' do
        expect_no_offenses(<<~RUBY)
          # @api public
          # @author John Smith
          # @example
          #   my_method("test")
          # @param param1 [String] the input parameter
          # @return [void]
          # @since 1.0.0
          def my_method(param1)
            puts param1
          end
        RUBY
      end
    end

    context 'when checking modules' do
      it 'is expected to register an offense for missing required tags' do
        expect_offense(<<~RUBY)
          # Missing tags comment
          module MyModule
          ^^^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @since
          end
        RUBY
      end

      it 'is expected not to register an offense when all required tags are present' do
        expect_no_offenses(<<~RUBY)
          # @api public
          # @author John Smith
          # @since 1.0.0
          module MyModule
          end
        RUBY
      end
    end

    context 'when checking constants' do
      it 'is expected to register an offense for missing required tags' do
        expect_offense(<<~RUBY)
          # Missing tags comment
          CONSTANT = "value"
          ^^^^^^^^^^^^^^^^^^ Missing required YARD tag(s): @api, @author, @return, @since
        RUBY
      end

      it 'is expected not to register an offense when all required tags are present' do
        expect_no_offenses(<<~RUBY)
          # @api public
          # @author John Smith
          # @since 1.0.0
          # @return [String]
          CONSTANT = "value"
        RUBY
      end
    end
  end
end
