# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/domainic/dev/base'

module RuboCop
  module Cop
    module Domainic
      module Dev
        module YARD
          # This cop ensures that all classes, constants, methods, and modules have YARD documentation
          # It enforces basic documentation presence across the codebase by checking for non-empty
          # yard_docstrings on all major code elements
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @example
          #   # bad
          #   class MyClass
          #   end
          #
          #   # good
          #   # A class that does something.
          #   class MyClass
          #   end
          #
          # @example
          #   # bad
          #   CONSTANT = "value"
          #
          #   # good
          #   # A constant that holds a value
          #   CONSTANT = "value"
          #
          # @example
          #   # bad
          #   def my_method
          #   end
          #
          #   # good
          #   # A method that does something.
          #   def my_method
          #   end
          #
          # @example
          #   # bad
          #   module MyModule
          #   end
          #
          #   # good
          #   # A module that provides functionality
          #   module MyModule
          #   end
          class Documentation < Base
            # The Error message used for offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [String] the error message
            MSG = 'Missing YARD documentation for `%<type>s %<identifier>s`' #: String

            # The constant assignment hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_casgn(node)
              return unless cop_config['Constant'] == true

              node = wrapped_node(node) #: RuboCop::Domainic::Dev::AST::ConstantNodeWrapper
              return unless node.yard_docstring&.raw_text&.empty?

              add_offense(
                node.loc.expression, # steep:ignore NoMethod
                message: format(MSG, type: 'constant', identifier: node.const_name) # steep:ignore NoMethod
              )
            end

            # The class hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the class node
            # @return [void]
            # @rbs (untyped node) -> void
            def on_class(node)
              return unless cop_config['Class'] == true

              node = wrapped_node(node) #: RuboCop::Domainic::Dev::AST::ClassNodeWrapper
              return unless node.yard_docstring&.raw_text&.empty?
              return unless node.innermost_constant?

              add_offense(
                node.loc.expression, # steep:ignore NoMethod
                message: format(MSG, type: node.type, identifier: identifier(node)) # steep:ignore NoMethod
              )
            end

            # The method def hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the method node
            # @return [void]
            # @rbs (untyped node) -> void
            def on_def(node)
              return unless cop_config['Method'] == true

              node = wrapped_node(node) #: RuboCop::Domainic::Dev::AST::MethodNodeWrapper
              return unless node.yard_docstring&.raw_text&.empty?

              add_offense(
                node.loc.expression, # steep:ignore NoMethod
                message: format(MSG, type: :method, identifier: node.method_name) # steep:ignore NoMethod
              )
            end
            alias on_defs on_def

            # The module hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the module node
            # @return [void]
            # @rbs (untyped node) -> void
            def on_module(node)
              return unless cop_config['Module'] == true

              node = wrapped_node(node) #: RuboCop::Domainic::Dev::AST::ModuleNodeWrapper
              return unless node.yard_docstring&.raw_text&.empty?
              return unless node.innermost_constant?

              add_offense(
                node.loc.expression, # steep:ignore NoMethod
                message: format(MSG, type: node.type, identifier: identifier(node)) # steep:ignore NoMethod
              )
            end

            # The method send hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the method node
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_send(node)
              return unless cop_config['Attribute'] == true
              return unless attribute_method?(node)

              node = wrapped_node(node)
              return unless node.yard_docstring&.raw_text&.empty?

              add_offense(
                node.loc.expression, # steep:ignore NoMethod
                message: format(MSG, type: :attribute, identifier: node.arguments.first.value) # steep:ignore NoMethod
              )
            end

            private

            # Identity a class or module node by its ancestors
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::Node] the node to check
            # @return [String] the identifier
            # @rbs (untyped node) -> String
            def identifier(node)
              nodes = [node, *node.each_ancestor(:class, :module)]
              identifier = nodes.reverse_each.flat_map do |n|
                qualify_const(n.identifier)
              end.join('::')

              identifier.sub('::::', '::')
            end

            # Qualify the class or module name
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::Node] the node to check
            # @return [Array<String>, String, nil] the qualified constant
            # @rbs (untyped node) -> (String | Array[String])?
            def qualify_const(node)
              return if node.nil?

              if node.cbase_type? || node.self_type? || node.call_type? || node.variable?
                node.source
              else
                [qualify_const(node.namespace), node.short_name].compact
              end
            end
          end
        end
      end
    end
  end
end
