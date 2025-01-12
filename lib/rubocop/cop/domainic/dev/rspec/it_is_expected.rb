# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/domainic/dev/base'

module RuboCop
  module Cop
    module Domainic
      module Dev
        module RSpec
          # This cop ensures that `it` blocks in RSpec examples begin with "is expected" in their descriptions
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @example
          #   # bad
          #   it "returns a String" do
          #     expect(my_method).to be_a(String)
          #   end
          #
          #   # good
          #   it "is expected to return a String" do
          #     expect(my_method).to be_a(String)
          #   end
          class ItIsExpected < Base
            # The Error message used for offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [String] the error message
            MSG = 'Described RSpec `it` blocks should start with "is expected"' #: String

            # Match `it "..." do ... end` or `it(...) { ... }`
            def_node_matcher :it_with_description?, <<~PATTERN
              (send nil? :it (str $_) ...)
            PATTERN

            # @rbs! def it_with_description?: (untyped node) -> String?

            # The RuboCop on send hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_send(node)
              description = it_with_description?(node)
              return unless description

              # Skip examples that already start with "is expected"
              return if description.start_with?('is expected')

              add_offense(node.loc.selector, message: MSG)
            end
          end
        end
      end
    end
  end
end
