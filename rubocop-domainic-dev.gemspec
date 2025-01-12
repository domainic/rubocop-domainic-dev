# frozen_string_literal: true

RUBOCOP_DOMAINIC_DEV_GEM_VERSION = '0.0.1'
RUBOCOP_DOMAINIC_DEV_SEMVER = '0.0.1'
RUBOCOP_DOMAINIC_DEV_REPO_URL = 'https://github.com/domainic/rubocop-domainic-dev'
RUBOCOP_DOMAINIC_DEV_HOME_URL = 'https://domainic.org'

Gem::Specification.new do |spec|
  spec.name        = 'rubocop-domainic-dev'
  spec.version     = RUBOCOP_DOMAINIC_DEV_GEM_VERSION
  spec.homepage    = RUBOCOP_DOMAINIC_DEV_HOME_URL
  spec.authors     = ['Aaron Allen']
  spec.email       = ['hello@aaronmallen.me']
  spec.summary     = 'Custom RuboCop cops and shared configurations for Domainic gem development'
  spec.description = 'The rubocop-domainic-dev gem provides custom RuboCop cops and shared' \
                     'configurations to enforce consistent code style and best practices across the' \
                     'Domainic gem ecosystem. It includes specialized cops for RSpec formatting and' \
                     'documentation standards, along with preset RuboCop configurations that can be' \
                     'inherited by other Domainic gems.'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir.chdir(__dir__) do
    Dir['{config,lib,sig}/**/*', '.yardopts', 'CHANGELOG.md', 'LICENSE', 'README.md']
      .reject { |f| File.directory?(f) }
  end

  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{RUBOCOP_DOMAINIC_DEV_REPO_URL}/issues",
    'changelog_uri' => "#{RUBOCOP_DOMAINIC_DEV_REPO_URL}/releases/tag/v#{RUBOCOP_DOMAINIC_DEV_SEMVER}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{RUBOCOP_DOMAINIC_DEV_REPO_URL}/tree/v#{RUBOCOP_DOMAINIC_DEV_SEMVER}"
  }

  spec.add_dependency 'rubocop', '~> 1.70'
  spec.add_dependency 'rubocop-on-rbs', '~> 1.3'
  spec.add_dependency 'rubocop-ordered_methods', '~> 0.13'
  spec.add_dependency 'rubocop-performance', '~> 1.23'
  spec.add_dependency 'rubocop-rspec', '~> 3.3'
  spec.add_dependency 'rubocop-yard', '~> 0.10'
end
