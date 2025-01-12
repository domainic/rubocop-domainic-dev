# frozen_string_literal: true

require 'yard'

module RuboCop
  module Domainic
    module Dev
      module AST
        # The base class for all Domainic Dev AST node wrappers
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.2.0
        #
        # @abstract Subclass and implement node behavior
        # @api private
        class NodeWrapper
          # The processed source of the wrapper
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [RuboCop::AST::ProcessedSource]
          attr_reader :processed_source #: RuboCop::AST::ProcessedSource

          # The source node for the wrapper
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [RuboCop::AST::Node]
          attr_reader :source_node #: untyped

          # Initialize a new instance of MethodNode
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @param processed_source [RuboCop::AST::ProcessedSource] the processed source for the node
          # @param source_node [Rubocop::AST::Node] the source node
          #
          # @return [MethodNodeWrapper] the new instance of MethodNode
          # @rbs (untyped process_source, untyped source_node) -> void
          def initialize(processed_source, source_node)
            @processed_source = processed_source
            @source_node = source_node
          end

          # Get the raw ast comments for the node
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Array<Parser::Source::Comment>] the raw ast comments
          # @rbs () -> Array[Parser::Source::Comment]
          def comments
            @comments ||= begin
              consecutive = [] #: Array[Parser::Source::Comment]
              last_line = nil

              # steep:ignore:start
              ast_comments.sort_by { |c| c.loc.line }.each do |comment|
                last_line.nil? || comment.loc.line == last_line + 1 ? consecutive << comment : consecutive = [comment]
                last_line = comment.loc.line
              end
              # steep:ignore:end

              consecutive
            end
          end

          # Get the entire yard docstring for the method
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [RuboCop::AST::Node] the docstring node
          # @rbs () -> untyped
          def yard_docstring
            @yard_docstring ||= begin
              comment_texts = ast_comments.map { |l| l.text.delete_prefix('#') } # steep:ignore
              minimum_space = comment_texts.filter_map { |t| t.index(/[^\s]/) }.min
              yard_docstring = comment_texts.map { |t| t[minimum_space..] }.join("\n")
              ::YARD::Logger.instance.enter_level(::YARD::Logger::ERROR) do # steep:ignore NoMethod
                ::YARD::DocstringParser.new.parse(yard_docstring)
              end
            rescue StandardError
              nil
            end
          end

          private

          # Get the yard docstring of the node
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [String] the yard_docstring
          # @rbs () -> Array[Parser::Source::Comment]
          def ast_comments
            @ast_comments ||= @processed_source.ast_with_comments[@source_node] # steep:ignore NoMethod
          end

          # Delegate missing methods to the source node
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @param method_name [String, Symbol] the name of the missing method
          #
          # @raise [NoMethodError] if the source node does not respond to the missing method
          # @return [Object] the response from the source node
          # @rbs (String | Symbol method_name, *untyped, **untyped) -> untyped
          def method_missing(method_name, ...)
            return super unless respond_to_missing?(method_name)

            @source_node.send(method_name, ...)
          end

          # Check if the source node responds to a missing method
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @param method_name [String, Symbol] the method name to check
          # @param _include_private [Boolean] whether to include private methods in the check
          #
          # @return [Boolean] `true` if the source node responds to the method, `false` otherwise
          # @rbs (String | Symbol method_name, ?bool include_private) -> bool
          def respond_to_missing?(method_name, _include_private = false)
            @source_node.respond_to?(method_name) || super
          end
        end
      end
    end
  end
end
