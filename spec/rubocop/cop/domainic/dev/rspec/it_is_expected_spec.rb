# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'

RSpec.describe RuboCop::Cop::Domainic::Dev::RSpec::ItIsExpected do
  include RuboCop::RSpec::ExpectOffense

  describe '.cop_name' do
    subject(:cop_name) { described_class.cop_name }

    it { is_expected.to match 'RSpec/ItIsExpected' }
  end

  describe 'offenses' do
    subject(:cop) { described_class.new }

    it 'is expected to register an offense when description does not start with "is expected"' do
      expect_offense(<<~RUBY)
        it "should work" do; end
        ^^ RSpec/ItIsExpected: Described RSpec `it` blocks should start with "is expected"
      RUBY
    end

    it 'is expected not to register an offense when description starts with "is expected"' do
      expect_no_offenses(<<~RUBY)
        it "is expected to work" do
          expect(subject).to be true
        end
      RUBY
    end
  end
end
