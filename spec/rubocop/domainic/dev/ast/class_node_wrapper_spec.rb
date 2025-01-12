# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Domainic::Dev::AST::ClassNodeWrapper do
  let(:processed_source) { instance_double(RuboCop::AST::ProcessedSource) }
  let(:source_node) { instance_double(RuboCop::AST::Node) }
  let(:node) { described_class.new(processed_source, source_node) }
  let(:descendants) { [] }

  describe '#innermost_constant?' do
    subject(:innermost_constant?) { node.innermost_constant? }

    before do
      allow(source_node).to receive(:each_descendant).with(:class, :module).and_return(descendants)
    end

    context 'when class has no descendants' do
      let(:descendants) { [].each }

      it { is_expected.to be true }
    end

    context 'when class has class/module descendants' do
      let(:nested_class) { instance_double(RuboCop::AST::Node) }
      let(:descendants) { [nested_class].each }

      it { is_expected.to be false }
    end
  end
end
