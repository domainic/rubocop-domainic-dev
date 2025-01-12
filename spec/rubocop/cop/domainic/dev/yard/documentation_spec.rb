# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'

RSpec.describe RuboCop::Cop::Domainic::Dev::YARD::Documentation do
  include RuboCop::RSpec::ExpectOffense

  describe '.cop_name' do
    subject(:cop_name) { described_class.cop_name }

    it { is_expected.to match 'YARD/Documentation' }
  end

  describe 'offenses' do
    subject(:cop) { described_class.new(config) }

    let(:config) do
      RuboCop::Config.new(
        'YARD/Documentation' => {
          'Attribute' => true,
          'Class' => true,
          'Constant' => true,
          'Method' => true,
          'Module' => true
        }
      )
    end

    context 'when checking attributes' do
      context 'when Attribute checking is enabled' do
        it 'is expected to register an offense for missing documentation' do
          expect_offense(<<~RUBY)
            attr_accessor :my_accessor
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `attribute my_accessor`
            attr_reader :my_reader
            ^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `attribute my_reader`
            attr_writer :my_writer
            ^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `attribute my_writer`
          RUBY
        end

        it 'is expected to register an offense for empty documentation' do
          expect_offense(<<~RUBY)
            #
            attr_accessor :my_accessor
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `attribute my_accessor`
            #
            attr_reader :my_reader
            ^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `attribute my_reader`
            #
            attr_writer :my_writer
            ^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `attribute my_writer`
          RUBY
        end

        it 'is expected not to register an offense when documentation is present' do
          expect_no_offenses(<<~RUBY)
            # An attribute accessor
            attr_accessor :my_accessor
            # An attribute reader
            attr_reader :my_reader
            # An attribute writer
            attr_writer :my_writer
          RUBY
        end
      end

      context 'when Attribute checking is disabled' do
        let(:config) do
          RuboCop::Config.new(
            'YARD/Documentation' => {
              'Attribute' => false
            }
          )
        end

        it 'is expected not to register an offense for missing documentation' do
          expect_no_offenses(<<~RUBY)
            attr_accessor :my_accessor
            attr_reader :my_reader
            attr_writer :my_writer
          RUBY
        end
      end
    end

    context 'when checking classes' do
      context 'when Class checking is enabled' do
        it 'is expected to register an offense for missing documentation' do
          expect_offense(<<~RUBY)
            class MyClass
            ^^^^^^^^^^^^^ Missing YARD documentation for `class MyClass`
            end
          RUBY
        end

        it 'is expected to register an offense for empty documentation' do
          expect_offense(<<~RUBY)
            #
            class MyClass
            ^^^^^^^^^^^^^ Missing YARD documentation for `class MyClass`
            end
          RUBY
        end

        it 'is expected not to register an offense when documentation is present' do
          expect_no_offenses(<<~RUBY)
            # A class that does something.
            class MyClass
            end
          RUBY
        end

        it 'is expected to register an offense for the innermost class' do
          expect_offense(<<~RUBY)
            # Outer class documentation
            class OuterClass
              class InnerClass
              ^^^^^^^^^^^^^^^^ Missing YARD documentation for `class OuterClass::InnerClass`
              end
            end
          RUBY
        end
      end

      context 'when Class checking is disabled' do
        let(:config) do
          RuboCop::Config.new(
            'YARD/Documentation' => {
              'Class' => false
            }
          )
        end

        it 'is expected not to register an offense for missing documentation' do
          expect_no_offenses(<<~RUBY)
            class MyClass
            end
          RUBY
        end
      end
    end

    context 'when checking constants' do
      context 'when Constant checking is enabled' do
        it 'is expected to register an offense for missing documentation' do
          expect_offense(<<~RUBY)
            CONSTANT = "value"
            ^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `constant CONSTANT`
          RUBY
        end

        it 'is expected to register an offense for empty documentation' do
          expect_offense(<<~RUBY)
            #
            CONSTANT = "value"
            ^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `constant CONSTANT`
          RUBY
        end

        it 'is expected not to register an offense when documentation is present' do
          expect_no_offenses(<<~RUBY)
            # A constant that holds a value.
            CONSTANT = "value"
          RUBY
        end
      end

      context 'when Constant checking is disabled' do
        let(:config) do
          RuboCop::Config.new(
            'YARD/Documentation' => {
              'Constant' => false
            }
          )
        end

        it 'is expected not to register an offense for missing documentation' do
          expect_no_offenses(<<~RUBY)
            CONSTANT = "value"
          RUBY
        end
      end
    end

    context 'when checking methods' do
      context 'when Method checking is enabled' do
        it 'is expected to register an offense for missing documentation' do
          expect_offense(<<~RUBY)
            def my_method
            ^^^^^^^^^^^^^ Missing YARD documentation for `method my_method`
            end
          RUBY
        end

        it 'is expected to register an offense for empty documentation' do
          expect_offense(<<~RUBY)
            #
            def my_method
            ^^^^^^^^^^^^^ Missing YARD documentation for `method my_method`
            end
          RUBY
        end

        it 'is expected not to register an offense when documentation is present' do
          expect_no_offenses(<<~RUBY)
            # A method that does something.
            def my_method
            end
          RUBY
        end

        it 'is expected to register an offense for singleton methods with missing documentation' do
          expect_offense(<<~RUBY)
            def self.my_singleton_method
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `method my_singleton_method`
            end
          RUBY
        end
      end

      context 'when Method checking is disabled' do
        let(:config) do
          RuboCop::Config.new(
            'YARD/Documentation' => {
              'Method' => false
            }
          )
        end

        it 'is expected not to register an offense for missing documentation' do
          expect_no_offenses(<<~RUBY)
            def my_method
            end
          RUBY
        end
      end
    end

    context 'when checking modules' do
      context 'when Module checking is enabled' do
        it 'is expected to register an offense for missing documentation' do
          expect_offense(<<~RUBY)
            module MyModule
            ^^^^^^^^^^^^^^^ Missing YARD documentation for `module MyModule`
            end
          RUBY
        end

        it 'is expected to register an offense for empty documentation' do
          expect_offense(<<~RUBY)
            #
            module MyModule
            ^^^^^^^^^^^^^^^ Missing YARD documentation for `module MyModule`
            end
          RUBY
        end

        it 'is expected not to register an offense when documentation is present' do
          expect_no_offenses(<<~RUBY)
            # A module that provides functionality.
            module MyModule
            end
          RUBY
        end

        it 'is expected to register an offense for the innermost module' do
          expect_offense(<<~RUBY)
            # Outer module documentation
            module OuterModule
              module InnerModule
              ^^^^^^^^^^^^^^^^^^ Missing YARD documentation for `module OuterModule::InnerModule`
              end
            end
          RUBY
        end
      end

      context 'when Module checking is disabled' do
        let(:config) do
          RuboCop::Config.new(
            'YARD/Documentation' => {
              'Module' => false
            }
          )
        end

        it 'is expected not to register an offense for missing documentation' do
          expect_no_offenses(<<~RUBY)
            module MyModule
            end
          RUBY
        end
      end
    end
  end
end
