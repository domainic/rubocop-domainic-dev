# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Domainic::Dev::AST::ModuleNodeWrapper do
  let(:processed_source) { instance_double(RuboCop::AST::ProcessedSource) }
  let(:source_node) { instance_double(RuboCop::AST::Node) }
  let(:node) { described_class.new(processed_source, source_node) }
  let(:descendants) { [] }

  describe '#innermost_constant?' do
    subject(:innermost_constant?) { node.innermost_constant? }

    before do
      allow(source_node).to receive(:each_descendant).with(:class, :module).and_return(descendants)
    end

    context 'when module has no descendants' do
      let(:descendants) { [].each }

      it { is_expected.to be true }
    end

    context 'when module has class/module descendants' do
      let(:nested_module) { instance_double(RuboCop::AST::Node) }
      let(:descendants) { [nested_module].each }

      it { is_expected.to be false }
    end
  end
end
