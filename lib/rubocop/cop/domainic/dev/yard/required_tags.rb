# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/domainic/dev/base'
require 'rubocop/cop/domainic/dev/yard/config/required_tags'

module RuboCop
  module Cop
    module Domainic
      module Dev
        module YARD
          # This cop ensures that all specified required YARD tags are included on classes, constants, methods and
          # modules. It enforces consistent documentation standards across the codebase by checking for required
          # tags and conditionally required tags based on method characteristics
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @example With default configuration
          #   # bad
          #   # My class description
          #   class MyClass; end
          #
          #   # good
          #   # My class description
          #   #
          #   # @api public
          #   # @author Aaron Allen
          #   # @since 0.2.0
          #   class MyClass; end
          #
          # @example RequireExampleOnPublicMethods: true (default)
          #   # bad - missing @example for public method
          #   # @api public
          #   # @author John Smith
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_public_method; end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @example
          #   #   my_public_method
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_public_method; end
          #
          # @example RequireParams: true (default)
          #   # bad - missing @param for argument
          #   # @api public
          #   # @author John Smith
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_method(name); end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @param name [String] the name parameter
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_method(name); end
          #
          # @example RequireRaise: true (default)
          #   # bad - missing @raise tag
          #   # @api public
          #   # @author John Smith
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_method
          #     raise StandardError
          #   end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @raise [StandardError] when something goes wrong
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_method
          #     raise StandardError
          #   end
          #
          # @example RequireYield: true (default)
          #   # bad - missing @yield tag
          #   # @api public
          #   # @author John Smith
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_method
          #     yield
          #   end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @return [void]
          #   # @since 1.0.0
          #   # @yield [block] yields to the block
          #   def my_method
          #     yield
          #   end
          #
          # @example RequiredTags for classes
          #   # bad - missing required tags
          #   class MyClass; end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @since 1.0.0
          #   class MyClass; end
          #
          # @example RequiredTags for constants
          #   # bad - missing required tags
          #   CONSTANT = "value"
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @return [String] a value
          #   # @since 1.0.0
          #   CONSTANT = "value"
          #
          # @example RequiredTags for methods
          #   # bad - missing required tags
          #   def my_method; end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @return [void]
          #   # @since 1.0.0
          #   def my_method; end
          #
          # @example RequiredTags for modules
          #   # bad - missing required tags
          #   module MyModule; end
          #
          #   # good
          #   # @api public
          #   # @author John Smith
          #   # @since 1.0.0
          #   module MyModule; end
          class RequiredTags < Base
            # The Error message used for offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [String] the error message
            MSG = 'Missing required YARD tag(s): %<missing>s' #: String

            # The constant assignment hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the constant node
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_casgn(node)
              node = wrapped_node(node)
              return if node.yard_docstring.nil? || node.yard_docstring.raw_text.empty?

              check_tags(node, cop_config.required_constant_tags)
            end

            # The class hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the class node
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_class(node)
              node = wrapped_node(node) #: RuboCop::Domainic::Dev::AST::ModuleNodeWrapper
              return unless node.innermost_constant?
              return if node.yard_docstring.nil? || node.yard_docstring.raw_text.empty?

              check_tags(node, cop_config.required_class_tags)
            end
            alias on_module on_class

            # The method def hook
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
            def on_def(node)
              node = wrapped_node(node)
              return if node.yard_docstring.nil? || node.yard_docstring.raw_text.empty?

              check_tags(node, cop_config.required_method_tags)
              check_conditional_tags(node)
            end
            alias on_defs on_def

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
              return unless attribute_method?(node)

              node = wrapped_node(node)
              check_tags(node, cop_config.required_attribute_tags)
            end

            private

            # Add an offense
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::NodeWrapper] the node to add an offense for
            # @param missing_tags [Array<String>] the missing tags for the offense
            #
            # @return [void]
            # @rbs (untyped node, missing_tags: Array[String]) -> void
            def add_offense(node, missing_tags:)
              super(
                node.loc.expression,
                message: format(MSG, missing: missing_tags.map { |tag| "@#{tag}" }.join(', '))
              )
            end

            # Check method nodes for conditionally required tags
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::MethodNode] the node to check
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def check_conditional_tags(node)
              existing_tags = node.yard_docstring.tags.map(&:tag_name)
              required_tags = %w[param example raise yield].select { |tag| send(:"require_#{tag}?", node) }

              missing_tags = required_tags - existing_tags
              return if missing_tags.empty?

              add_offense(node, missing_tags:)
            end

            # Check for missing required tags
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::Node] the node to check
            # @param required_tags [Array<String>] the required tags
            #
            # @return [void]
            # @rbs (untyped node, Array[String] required_tags) -> void
            def check_tags(node, required_tags)
              return if required_tags.empty?

              missing_tags = required_tags - node.yard_docstring.tags.map(&:tag_name)
              return if missing_tags.empty?

              add_offense(node, missing_tags:)
            end

            # Check if the @example tag is required for a method
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::MethodNode] the node to check
            #
            # @return [Boolean] `true` if all examples are required, `false` otherwise
            # @rbs (untyped node) -> bool
            def require_example?(node)
              return false unless cop_config.require_example_tag_on_public_methods?

              node.public?
            end

            # Check if the @params tag is required for a method
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::MethodNode] the node to check
            #
            # @return [Boolean] `true` if all params are documented, `false` otherwise
            # @rbs (untyped node) -> bool
            def require_param?(node)
              return false unless cop_config.require_param_tag?
              return false unless node.arguments.any?

              docs = node.yard_docstring.tags.select { |tag| tag.tag_name == 'param' }.map { |tag| tag.name.to_s }
              (node.param_names - docs).empty?
            end

            # Check if the @raise tag is required for a method
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::MethodNode] the node to check
            #
            # @return [Boolean] `true` if raise is required, `false` otherwise
            # @rbs (untyped node) -> bool
            def require_raise?(node)
              return false unless cop_config.require_raise_tag?

              node.raises?
            end

            # Check if the @yield tag is required for a method
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::MethodNode] the node to check
            #
            # @return [Boolean] `true` if yield is required, `false` otherwise
            # @rbs (untyped node) -> bool
            def require_yield?(node)
              return false unless cop_config.require_yield_tag?

              node.yields?
            end
          end
        end
      end
    end
  end
end
