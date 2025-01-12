# frozen_string_literal: true

require 'rubocop/domainic/dev/ast/node_wrapper'

module RuboCop
  module Domainic
    module Dev
      module AST
        # A wrapper for module RuboCop::AST::Nodes
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.2.0
        #
        # @api private
        class ModuleNodeWrapper < NodeWrapper
          # Check if this module is the innermost constant definition in its file
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] true if this is the innermost constant definition
          # @rbs () -> bool
          def innermost_constant?
            @source_node.each_descendant(:class, :module).none?
          end
        end
      end
    end
  end
end
