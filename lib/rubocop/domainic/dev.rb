# frozen_string_literal: true

require 'pathname'
require 'rubocop'

module RuboCop
  module Domainic
    # Domainic Dev RuboCop
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.2.0
    #
    # @api private
    module Dev
      # The project root path
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.2.0
      #
      # @api private
      #
      # @return [Pathname] the project root path
      PROJECT_ROOT = Pathname.new(File.dirname(__FILE__)).parent.parent.parent.expand_path.freeze #: Pathname
      private_constant :PROJECT_ROOT

      # The default configuration file for Domainic RuboCop cops
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.2.0
      #
      # @api private
      #
      # @return [Pathname] the configuration file path
      CONFIG_DEFAULT = PROJECT_ROOT.join('config', 'default.yml').freeze #: Pathname
      private_constant :CONFIG_DEFAULT

      # Inject the Domainic Cop defaults
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.2.0
      #
      # @api private
      #
      # @return [void]
      # @rbs () -> void
      def self.inject_configuration_defaults!
        path = CONFIG_DEFAULT.to_s
        hash = ConfigLoader.send(:load_yaml_configuration, path)
        config = Config.new(hash, path)
        puts "configuration from #{path}" if ConfigLoader.debug?
        config = ConfigLoader.merge_with_default(config, path)
        ConfigLoader.instance_variable_set(:@default_configuration, config)
      end
    end
  end
end

Dir.glob(File.expand_path('dev/**/*.rb', File.dirname(__FILE__))).each { |file| require file }
