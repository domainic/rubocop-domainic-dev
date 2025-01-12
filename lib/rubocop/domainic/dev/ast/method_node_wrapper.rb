# frozen_string_literal: true

require 'rubocop/domainic/dev/ast/node_wrapper'

module RuboCop
  module Domainic
    module Dev
      module AST
        # A wrapper for method RuboCop::AST::Nodes
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.2.0
        #
        # @api private
        class MethodNodeWrapper < NodeWrapper
          # Get the list of param names from the method arguments
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Array<String>] the param names
          # @rbs () -> Array[String]
          def param_names
            @source_node.arguments.map { |argument| argument.children.first.to_s }
          end

          # Check if the method is private
          #
          # A method is considered private if:
          # - It has private visibility in Ruby code OR
          # - It has @api private, @!visibility private, or @private in its documentation
          # UNLESS
          # - It has an @api public tag which overrides other visibility indicators
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] true if the method is private
          # @rbs () -> bool
          def private?
            return false if api_visibility == 'public'

            private_from_docs? || ruby_visibility == :private
          end

          # Check if the method is protected
          #
          # A method is considered protected if:
          # - It has protected visibility in Ruby code OR
          # - It has a @!visibility protected tag in its documentation
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] true if the method is protected
          # @rbs () -> bool
          def protected?
            return true if visibility_tag == 'protected'

            ruby_visibility == :protected
          end

          # Check if the method is public
          #
          # A method is considered public if:
          # - It has default public visibility in Ruby code AND
          # - It does not have any documentation tags indicating private visibility
          # OR
          # - It has an @api public tag in its documentation
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] true if the method is public
          # @rbs () -> bool
          def public?
            return true if api_visibility == 'public'
            return false if private_from_docs?

            ruby_visibility == :public
          end

          # Check if the method raises an error
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] `true` if the method raises an error, `false` otherwise
          # @rbs () -> bool
          def raises?
            raise_methods = %i[raise fail]
            @source_node.each_descendant(:send).any? do |send_node|
              raise_methods.include?(send_node.method_name)
            end
          end

          # Check if the method yields
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] `true` if the method yields, `false` otherwise
          # @rbs () -> bool
          def yields?
            @source_node.each_descendant(:yield).any?
          end

          private

          # Get the API visibility from the documentation
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [String, nil] the API visibility or nil if not specified
          # @rbs () -> String?
          def api_visibility
            return nil if yard_docstring.nil?

            api_tag = yard_docstring.tags.find { |tag| tag.tag_name == 'api' }
            api_tag&.text
          end

          # Check if the method is marked as private in its documentation
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Boolean] true if the method is marked as private in docs
          # @rbs () -> bool
          def private_from_docs?
            return false if yard_docstring.nil?

            api_visibility == 'private' ||
              visibility_tag == 'private' ||
              yard_docstring.tags.any? { |tag| tag.tag_name == 'private' }
          end

          # Get the method's Ruby visibility by checking for the last visibility modifier
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Symbol] :public, :protected, or :private
          # @rbs () -> Symbol
          def ruby_visibility
            visibility = :public
            ancestors = @source_node.each_ancestor(:send).to_a
            visibility_modifiers = %i[private protected public]
            ancestors.reverse_each do |node|
              next unless visibility_modifiers.include?(node.method_name)

              visibility = node.method_name
              break # Take the closest visibility modifier
            end
            visibility
          end

          # Get the visibility from @!visibility tag
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [String, nil] the visibility or nil if not specified
          # @rbs () -> String?
          def visibility_tag
            return nil if yard_docstring.nil?

            visibility_tag = yard_docstring.directives.find { |directive| directive.tag.tag_name == 'visibility' }
            visibility_tag&.tag&.text
          end
        end
      end
    end
  end
end
