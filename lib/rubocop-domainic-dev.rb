# frozen_string_literal: true

require 'rubocop'
require_relative 'rubocop/domainic/dev'

RuboCop::Domainic::Dev.inject_configuration_defaults!

require_relative 'rubocop/cop/domainic/dev_cops'
