# frozen_string_literal: true

require 'rubocop/domainic/dev/ast/node_wrapper'

module RuboCop
  module Domainic
    module Dev
      module AST
        # A wrapper for constant RuboCop::AST::Nodes
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.2.0
        #
        # @api private
        class ConstantNodeWrapper < NodeWrapper
        end
      end
    end
  end
end
