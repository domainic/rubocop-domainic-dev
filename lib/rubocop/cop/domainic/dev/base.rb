# frozen_string_literal: true

require 'rubocop'
require 'rubocop/domainic/dev/ast/class_node_wrapper'
require 'rubocop/domainic/dev/ast/constant_node_wrapper'
require 'rubocop/domainic/dev/ast/method_node_wrapper'
require 'rubocop/domainic/dev/ast/module_node_wrapper'
require 'rubocop/domainic/dev/ast/node_wrapper'

module RuboCop
  module Cop
    module Domainic
      module Dev
        # The base class for all Domainic::Dev cops
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.2.0
        #
        # @abstract Subclass and implement Cop behavior
        # @api private
        class Base < RuboCop::Cop::Base
          # Node wrapper mappings
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Hash{Symbol => Class<RuboCop::Domainic::Dev::AST::NodeWrapper>}]
          NODE_WRAPPER_MAP = {
            casgn: RuboCop::Domainic::Dev::AST::ConstantNodeWrapper,
            class: RuboCop::Domainic::Dev::AST::ClassNodeWrapper,
            def: RuboCop::Domainic::Dev::AST::MethodNodeWrapper,
            defs: RuboCop::Domainic::Dev::AST::MethodNodeWrapper,
            module: RuboCop::Domainic::Dev::AST::ModuleNodeWrapper
          }.freeze #: Hash[Symbol, singleton(RuboCop::Domainic::Dev::AST::NodeWrapper)]
          private_constant :NODE_WRAPPER_MAP

          # Override the default Badge for the Domainic::Dev cops
          #
          # This overrides the default RuboCop::Cop::Badge for Domainic::Dev cops to allow for nesting within the
          # RuboCop::Cop::Domainic::Dev namespace without requiring an overly verbose cop name
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Rubocop::Cop::Badge] the badge for the Cop
          # @rbs () -> untyped
          def self.badge
            @badge ||= Badge.for((name || '').split('::').last(2).join('::')) # steep:ignore UnknownConstant
          end

          def_node_matcher :attribute_method?, <<~PATTERN
            (send nil? /^attr_(accessor|reader|writer)$/ ...)
          PATTERN

          # @rbs! def attribute_method?: (untyped node) -> untyped

          # Override the default cop_config with custom config classes when they're available
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @return [Hash, Object] the cop configuration
          # @rbs () -> untyped
          def cop_config
            @cop_config ||= begin
              department, badge = (self.class.name || '').split('::').last(2)
              config_name = "#{department}::Config::#{badge}"
              config_class = if RuboCop::Cop::Domainic::Dev.const_defined?(config_name)
                               RuboCop::Cop::Domainic::Dev.const_get(config_name)
                             end
              default_config = @config.for_badge(self.class.badge)
              config_class.nil? ? default_config : config_class.new(default_config) # steep:ignore NoMethod
            end
          end

          private

          # Get a wrapped node
          #
          # @author {https://aaronmallen.me Aaron Allen}
          # @since 0.2.0
          #
          # @api private
          #
          # @param node [RuboCop::AST::Node] the node to wrap
          #
          # @return [RuboCop::Domainic::Dev::AST::NodeWrapper] the wrapped node
          # @rbs (untyped node) -> RuboCop::Domainic::Dev::AST::NodeWrapper
          def wrapped_node(node)
            wrapper = NODE_WRAPPER_MAP.fetch(node.type, RuboCop::Domainic::Dev::AST::NodeWrapper)
            wrapper.new(processed_source, node)
          end
        end
      end
    end
  end
end
