# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Domainic::Dev::YARD::Config::RequiredTags do
  subject(:config) { described_class.new(cop_config) }

  let(:cop_config) do
    {
      'ExcludedClasses' => ['ExcludedClass'],
      'ExcludedConstants' => ['EXCLUDED_CONSTANT'],
      'ExcludedMethods' => ['excluded_method'],
      'ExcludedModules' => ['ExcludedModule'],
      'RequireExampleOnPublicMethods' => true,
      'RequireParams' => true,
      'RequireRaise' => true,
      'RequireYield' => true,
      'RequiredTags' => {
        'Class' => %w[author since],
        'Constant' => %w[author since],
        'Method' => %w[author return],
        'Module' => %w[author api]
      }
    }
  end

  describe '.new' do
    it 'is expected to initialize with a configuration hash' do
      expect { config }.not_to raise_error
    end
  end

  describe '#[]' do
    it 'is expected to fetch a configuration property directly' do
      expect(config['ExcludedClasses']).to eq(['ExcludedClass'])
    end

    it 'is expected to return nil for non-existent properties' do
      expect(config['NonExistentProperty']).to be_nil
    end
  end

  describe '#class_excluded?' do
    it 'is expected to return true for excluded class names' do
      expect(config.class_excluded?('ExcludedClass')).to be true
    end

    it 'is expected to return false for non-excluded class names' do
      expect(config.class_excluded?('IncludedClass')).to be false
    end
  end

  describe '#constant_excluded?' do
    it 'is expected to return true for excluded constant names' do
      expect(config.constant_excluded?('EXCLUDED_CONSTANT')).to be true
    end

    it 'is expected to return false for non-excluded constant names' do
      expect(config.constant_excluded?('INCLUDED_CONSTANT')).to be false
    end
  end

  describe '#method_excluded?' do
    it 'is expected to return true for excluded method names' do
      expect(config.method_excluded?('excluded_method')).to be true
    end

    it 'is expected to return false for non-excluded method names' do
      expect(config.method_excluded?('included_method')).to be false
    end
  end

  describe '#module_excluded?' do
    it 'is expected to return true for excluded module names' do
      expect(config.module_excluded?('ExcludedModule')).to be true
    end

    it 'is expected to return false for non-excluded module names' do
      expect(config.module_excluded?('IncludedModule')).to be false
    end
  end

  describe '#require_example_tag_on_public_methods?' do
    it 'is expected to return the configured value' do
      expect(config.require_example_tag_on_public_methods?).to be true
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return false by default' do
        expect(config.require_example_tag_on_public_methods?).to be false
      end
    end
  end

  describe '#require_param_tag?' do
    it 'is expected to return the configured value' do
      expect(config.require_param_tag?).to be true
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return false by default' do
        expect(config.require_param_tag?).to be false
      end
    end
  end

  describe '#require_raise_tag?' do
    it 'is expected to return the configured value' do
      expect(config.require_raise_tag?).to be true
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return false by default' do
        expect(config.require_raise_tag?).to be false
      end
    end
  end

  describe '#require_yield_tag?' do
    it 'is expected to return the configured value' do
      expect(config.require_yield_tag?).to be true
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return false by default' do
        expect(config.require_yield_tag?).to be false
      end
    end
  end

  describe '#required_class_tags' do
    it 'is expected to return the configured required tags for classes' do
      expect(config.required_class_tags).to eq(%w[author since])
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return an empty array by default' do
        expect(config.required_class_tags).to eq([])
      end
    end
  end

  describe '#required_constant_tags' do
    it 'is expected to return the configured required tags for constants' do
      expect(config.required_constant_tags).to eq(%w[author since])
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return an empty array by default' do
        expect(config.required_constant_tags).to eq([])
      end
    end
  end

  describe '#required_method_tags' do
    it 'is expected to return the configured required tags for methods' do
      expect(config.required_method_tags).to eq(%w[author return])
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return an empty array by default' do
        expect(config.required_method_tags).to eq([])
      end
    end
  end

  describe '#required_module_tags' do
    it 'is expected to return the configured required tags for modules' do
      expect(config.required_module_tags).to eq(%w[author api])
    end

    context 'when not configured' do
      let(:cop_config) { {} }

      it 'is expected to return the same tags as required_class_tags by default' do
        expect(config.required_module_tags).to eq(config.required_class_tags)
      end
    end
  end
end
