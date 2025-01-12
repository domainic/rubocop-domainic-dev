# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/domainic/dev/base'

module RuboCop
  module Cop
    module Domainic
      module Dev
        module YARD
          # This cop ensures that the first line of YARD docstrings is a description
          # It enforces that documentation starts with a descriptive text before any tags
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @example
          #   # bad
          #   # @author John Doe
          #   # @since 1.0
          #   class MyClass; end
          #
          #   # good
          #   # This class does something useful.
          #   #
          #   # @author John Doe
          #   # @since 1.0
          #   class MyClass; end
          #
          #   # bad
          #   # @api private
          #   def my_method; end
          #
          #   # good
          #   # Performs an important operation.
          #   #
          #   # @api private
          #   def my_method; end
          class Description < Base
            extend AutoCorrector

            # The Error message used for missing signature offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [String] the error message
            MISSING_MSG = 'Missing description in YARD docstring. The first line should be descriptive text' #: String

            # The Error message used for spacing offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [String] the error message
            SPACING_MSG = 'Missing blank line between description and YARD tags' #: String

            # The assignment hook
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_casgn(node)
              check_node(node)
            end
            alias on_class on_casgn
            alias on_def on_casgn
            alias on_defs on_casgn
            alias on_module on_casgn

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

              check_node(node)
            end

            private

            # Autocorrect the missing spacing between description and tags
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param corrector [RuboCop::Cop::Corrector] the corrector
            # @param tag_comment [RuboCop::AST::Comment] the comment to add a space to
            #
            # @return [void]
            # @rbs (untyped corrector, untyped tag_comment) -> void
            def autocorrect_spacing(corrector, tag_comment)
              corrector.insert_before(tag_comment.loc.expression, "#{leading_spaces(tag_comment)}#\n")
            end

            # Check if there is a blank line before the tag comment
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param comments [Array<RuboCop::AST::Comment>] the comments to check
            # @param tag_index [Integer] the index of the tag comment
            #
            # @return [Boolean] true if there is a blank line before the tag comment
            # @rbs (untyped comments, Integer) -> bool
            def blank_line_before_tag?(comments, tag_index)
              return false unless tag_index.positive?

              comments[tag_index - 1].text.delete_prefix('#').strip.empty?
            end

            # Check the description is present and not empty
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::NodeWrapper] the node to check
            #
            # @return [void]
            # @rbs (RuboCop::Domainic::Dev::AST::NodeWrapper node) -> void
            def check_description(node)
              first_line = node.comments.first.text.delete_prefix('#').strip # steep:ignore NoMethod
              return unless first_line.match?(/\A@(!)?[a-zA-Z]/)

              add_offense(node.loc.expression, message: MISSING_MSG) # steep:ignore NoMethod
            end

            # Check the node begins with a description
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::NodeWrapper]
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def check_node(node)
              node = wrapped_node(node)
              return if node.comments.empty?

              check_description(node)
              check_spacing(node)
            end

            # Check the spacing between description and tags is correct
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::Domainic::Dev::AST::NodeWrapper] the node to check
            #
            # @return [void]
            # @rbs (RuboCop::Domainic::Dev::AST::NodeWrapper node) -> void
            def check_spacing(node)
              tag_index = find_first_tag_index(node.comments)
              return unless tag_index
              return if blank_line_before_tag?(node.comments, tag_index)

              add_offense(node.loc.expression, message: SPACING_MSG) do |corrector| # steep:ignore NoMethod
                autocorrect_spacing(corrector, node.comments[tag_index])
              end
            end

            # Find the index of the first tag in the comments array
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param comments [Array<RuboCop::AST::Comment>] the comments to search
            #
            # @return [Integer, nil] the index of the first tag comment
            # @rbs (untyped comments) -> Integer?
            def find_first_tag_index(comments)
              comments.find_index do |comment|
                comment.text.delete_prefix('#').strip.match?(/\A@(!)?[a-zA-Z]/)
              end
            end

            # Add leading spaces to a comment
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param comment [RuboCop::AST::Comment] the comment to add spaces to
            #
            # @return [String, nil] the leading spaces
            # @rbs (untyped comment) -> String?
            def leading_spaces(comment)
              comment.text.match(/\A\s*/)[0]
            end
          end
        end
      end
    end
  end
end
