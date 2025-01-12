# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/domainic/dev/base'

module RuboCop
  module Cop
    module Domainic
      module Dev
        module YARD
          # This cop ensures that YARD docstrings don't end lines with periods
          # except for ellipsis (...) and code blocks
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @example
          #   # bad
          #   # This is a description.
          #   #
          #   # And this is more info.
          #   class MyClass; end
          #
          #   # good
          #   # This is a description
          #   #
          #   # And this is more info
          #   # with ellipsis...
          #   #
          #   # @example
          #   #   obj.method_name.
          #   #   something
          #   class MyClass; end
          class NoPeriod < Base
            extend AutoCorrector

            # The Error message used for offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @return [String] the error message
            MSG = 'YARD docstring lines should not end with periods'

            # Check nodes for period offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param node [RuboCop::AST::Node] the node to check
            #
            # @return [void]
            # @rbs (untyped node) -> void
            def on_casgn(node)
              check_node(wrapped_node(node))
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

              check_node(wrapped_node(node))
            end

            private

            # Add a period offense for a comment
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param comment [Parser::Source::Comment] the comment with the offense
            #
            # @return [void]
            # @rbs (Parser::Source::Comment comment) -> void
            def add_period_offense(comment)
              add_offense(comment) do |corrector|
                corrector.replace(comment, comment.text.chomp('.')) # steep:ignore NoMethod
              end
            end

            # Check comment lines for period offenses
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param comments [Array<Parser::Source::Comment>] the comments to check
            #
            # @return [void]
            # @rbs (Array[Parser::Source::Comment] comments) -> void
            def check_docstring_for_periods(comments)
              in_code_block = false

              comments.each do |comment|
                in_code_block = process_comment(comment, in_code_block)
              end
            end

            # Check a node's docstring for period offenses
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
            def check_node(node)
              return if node.comments.empty?

              check_docstring_for_periods(node.comments)
            end

            # Check if text is a code block delimiter
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param text [String] the text to check
            #
            # @return [Boolean] true if the text is a code block delimiter
            # @rbs (String text) -> bool
            def code_block_delimiter?(text)
              text.strip.match?(/^@example|^\s*```/)
            end

            # Check if the found period is an ellipsis
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param text [String] the text to check
            #
            # @return [Boolean] true if the period is part of an ellipsis
            # @rbs (String text) -> bool
            def ellipsis?(text)
              text.strip.end_with?('...')
            end

            # Check if the string ends with a period
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param text [String] the text to check
            #
            # @return [Boolean] true if the text ends with a period
            # @rbs (String text) -> bool
            def ends_with_period?(text)
              text.strip.end_with?('.') && !ellipsis?(text)
            end

            # Check if the text is a line continuation of the previous line
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param text [String] the text to check
            #
            # @return [Boolean] `true` if the line is a continuation, `false` otherwise
            # @rbs (String text) -> bool
            def line_continuation?(text)
              base_indent = text.index(/\S/) || 0
              text.match?(/^\s{#{base_indent + 1},}\S/)
            end

            # Process a single comment and maintain code block state
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param comment [Parser::Source::Comment] the comment to process
            # @param in_code_block [Boolean] current code block state
            #
            # @return [Boolean] new code block state
            # @rbs (Parser::Source::Comment comment, bool in_code_block) -> bool
            def process_comment(comment, in_code_block)
              text = comment.text.delete_prefix('#').rstrip # steep:ignore NoMethod

              return !in_code_block if code_block_delimiter?(text)

              return in_code_block if should_skip?(text, in_code_block)

              add_period_offense(comment) if ends_with_period?(text)
              in_code_block
            end

            # Check if a line should be skipped for period checking
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            #
            # @param text [String] the text to check
            # @param in_code_block [Boolean] whether currently in a code block
            #
            # @return [Boolean] true if the line should be skipped
            # @rbs (String text, bool in_code_block) -> bool
            def should_skip?(text, in_code_block)
              text.strip.empty? ||
                in_code_block ||
                ellipsis?(text) ||
                line_continuation?(text)
            end
          end
        end
      end
    end
  end
end
