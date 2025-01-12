# frozen_string_literal: true

module RuboCop
  module Cop
    module Domainic
      module Dev
        module YARD
          module Config
            # The configuration object for the RSpec/RequiredTags cop
            #
            # @author {https://aaronmallen.me Aaron Allen}
            # @since 0.2.0
            #
            # @api private
            class RequiredTags
              # Initialize a new instance of RequiredTagsConfig
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param cop_config [Hash{String => Object}] the default cop configuration
              #
              # @return [RequiredTagConfig] the new instance of RequiredTagsConfig
              # @rbs (Hash[String, untyped] cop_config) -> void
              def initialize(cop_config)
                @raw_config = cop_config
              end

              # Check if a class is excluded from the cop
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param class_name [String] the class name to check
              #
              # @return [Boolean] `true` if the class is excluded, `false` otherwise
              # @rbs (String class_name) -> bool
              def class_excluded?(class_name)
                from_config('ExcludedClasses', default: []).include?(class_name.to_s.strip)
              end

              # Check if a constant is excluded from the cop
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param constant_name [String] the constant name to check
              #
              # @return [Boolean] `true` if the constant is excluded, `false` otherwise
              # @rbs (String constant_name) -> bool
              def constant_excluded?(constant_name)
                from_config('ExcludedConstants', default: []).include?(constant_name.to_s.strip)
              end

              # Check if a method is excluded from the cop
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param method_name [String] the method name to check
              #
              # @return [Boolean] `true` if the method is excluded, `false` otherwise
              # @rbs (String method_name) -> bool
              def method_excluded?(method_name)
                from_config('ExcludedMethods', default: []).include?(method_name.to_s.strip)
              end

              # Check if a module is excluded from the cop
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param module_name [String] the module name to check
              #
              # @return [Boolean] `true` if the module is excluded, `false` otherwise
              # @rbs (String module_name) -> bool
              def module_excluded?(module_name)
                from_config('ExcludedModules', default: []).include?(module_name.to_s.strip)
              end

              # Check if the @example tag is required for public methods
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Boolean] `true` if the @example tag is required, `false` otherwise
              # @rbs () -> bool
              def require_example_tag_on_public_methods?
                from_config('RequireExampleOnPublicMethods', default: false)
              end

              # Check if the @param tag is required for methods that take arguments
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Boolean] `true` if the @param tag is required, `false` otherwise
              # @rbs () -> bool
              def require_param_tag?
                from_config('RequireParams', default: false)
              end

              # Check if the @raise tag is required for methods that raise
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Boolean] `true` if the @raise tag is required, `false` otherwise
              # @rbs () -> bool
              def require_raise_tag?
                from_config('RequireRaise', default: false)
              end

              # Check if the @yield tag is required for methods that yield
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Boolean] `true` if the @yield tag is required, `false` otherwise
              # @rbs () -> bool
              def require_yield_tag?
                from_config('RequireYield', default: false)
              end

              # Get the list of required attribute tags
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Array<String>] the required tags
              # @rbs () -> Array[String]
              def required_attribute_tags
                from_config('RequiredTags', 'Attribute', default: [])
              end

              # Get the list of required class tags
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Array<String>] the required tags
              # @rbs () -> Array[String]
              def required_class_tags
                from_config('RequiredTags', 'Class', default: [])
              end

              # Get the list of required constant tags
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Array<String>] the required tags
              # @rbs () -> Array[String]
              def required_constant_tags
                from_config('RequiredTags', 'Constant', default: [])
              end

              # Get the list of required method tags
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Array<String>] the required tags
              # @rbs () -> Array[String]
              def required_method_tags
                from_config('RequiredTags', 'Method', default: [])
              end

              # Get the list of required module tags
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Array<String>] the required tags
              # @rbs () -> Array[String]
              def required_module_tags
                from_config('RequiredTags', 'Module', default: required_class_tags)
              end

              private

              # The raw RuboCop configuration
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @return [Hash{String => Object}] the RuboCop configuration
              attr_reader :raw_config #: Hash[String, untyped]

              # Fetch a {#raw_config} value or return the default
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param keys [Array<String>] the keys to dig for
              # @param default [Object] the default value to use if the property is not found
              #
              # @return [Object] either the found configuration property or the provided default value
              # @rbs (*String keys, default: untyped) -> untyped
              def from_config(*keys, default:)
                config_property = raw_config.dig(*keys)
                config_property.nil? ? default : config_property
              end

              # Delegate missing methods to the raw configuration object
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param method_name [Symbol] the method to delegate
              #
              # @return [Object]
              # @rbs (Symbol method_name, *untyped, **untyped) -> untyped
              def method_missing(method_name, ...)
                return super unless respond_to_missing?(method_name)

                raw_config.send(method_name, ...)
              end

              # Check if the raw configuration object responds to a method
              #
              # @author {https://aaronmallen.me Aaron Allen}
              # @since 0.2.0
              #
              # @api private
              #
              # @param method_name [Symbol] the method to check
              # @param _include_private [Boolean] whether to include private methods in the check
              #
              # @return [Boolean] `true` if the configuration object responds to the method, `false` otherwise
              # @rbs (Symbol method_name, ?bool _include_private) -> bool
              def respond_to_missing?(method_name, _include_private = false)
                raw_config.respond_to?(method_name) || super
              end
            end
          end
        end
      end
    end
  end
end
