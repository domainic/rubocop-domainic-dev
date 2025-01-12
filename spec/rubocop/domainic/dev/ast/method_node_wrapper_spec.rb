# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Domainic::Dev::AST::MethodNodeWrapper do
  let(:processed_source) { instance_double(RuboCop::AST::ProcessedSource) }
  let(:source_node) { instance_double(RuboCop::AST::DefNode) }
  let(:node) { described_class.new(processed_source, source_node) }
  let(:yard_docstring) { instance_double(YARD::DocstringParser, tags: tags, directives: directives) }
  let(:directives) { [] }
  let(:tags) { [] }
  let(:ast_with_comments) { { source_node => [] } }

  before do
    allow(processed_source).to receive(:ast_with_comments).and_return(ast_with_comments)
  end

  describe '#param_names' do
    subject(:param_names) { node.param_names }

    let(:first_argument) { instance_double(RuboCop::AST::DefNode, children: ['foo']) }
    let(:second_argument) { instance_double(RuboCop::AST::DefNode, children: ['bar']) }

    before do
      allow(source_node).to receive(:arguments)
        .and_return([first_argument, second_argument])
    end

    it 'is expected to return an array of parameter names' do
      expect(param_names).to eq(%w[foo bar])
    end
  end

  describe '#public?' do
    subject(:public?) { node.public? }

    before do
      allow(source_node).to receive(:each_ancestor).with(:send).and_return([])
      allow(node).to receive(:yard_docstring).and_return(yard_docstring)
    end

    context 'when no visibility is specified' do
      it { is_expected.to be true }
    end

    context 'when method has @api public tag' do
      let(:tags) { [YARD::Tags::Tag.new(:api, 'public')] }

      it { is_expected.to be true }
    end

    context 'when private in Ruby but @api public in docs' do
      let(:tags) { [YARD::Tags::Tag.new(:api, 'public')] }
      let(:private_node) { instance_double(RuboCop::AST::SendNode, method_name: :private) }

      before do
        allow(source_node).to receive(:each_ancestor).with(:send).and_return([private_node])
      end

      it { is_expected.to be true }
    end

    context 'when method has @api private tag' do
      let(:tags) { [YARD::Tags::Tag.new(:api, 'private')] }

      it { is_expected.to be false }
    end

    context 'when method has @private tag' do
      let(:tags) { [YARD::Tags::Tag.new(:private, '')] }

      it { is_expected.to be false }
    end
  end

  describe '#protected?' do
    subject(:protected?) { node.protected? }

    before do
      allow(source_node).to receive(:each_ancestor).with(:send).and_return([])
      allow(node).to receive(:yard_docstring).and_return(yard_docstring)
    end

    context 'when no visibility is specified' do
      it { is_expected.to be false }
    end

    context 'when method has protected visibility in Ruby' do
      let(:protected_node) { instance_double(RuboCop::AST::SendNode, method_name: :protected) }

      before do
        allow(source_node).to receive(:each_ancestor).with(:send).and_return([protected_node])
      end

      it { is_expected.to be true }
    end

    context 'when method has @!visibility protected tag' do
      let(:directives) do
        [
          instance_double(
            YARD::Tags::VisibilityDirective,
            tag: YARD::Tags::Tag.new(:visibility, 'protected')
          )
        ]
      end

      it { is_expected.to be true }
    end
  end

  describe '#private?' do
    subject(:private?) { node.private? }

    before do
      allow(source_node).to receive(:each_ancestor).with(:send).and_return([])
      allow(node).to receive(:yard_docstring).and_return(yard_docstring)
    end

    context 'when no visibility is specified' do
      it { is_expected.to be false }
    end

    context 'when method has private visibility in Ruby' do
      let(:private_node) { instance_double(RuboCop::AST::SendNode, method_name: :private) }

      before do
        allow(source_node).to receive(:each_ancestor).with(:send).and_return([private_node])
      end

      it { is_expected.to be true }
    end

    context 'when method has @api private tag' do
      let(:tags) { [YARD::Tags::Tag.new(:api, 'private')] }

      it { is_expected.to be true }
    end

    context 'when method has @private tag' do
      let(:tags) { [YARD::Tags::Tag.new(:private, '')] }

      it { is_expected.to be true }
    end

    context 'when method has @!visibility private tag' do
      let(:directives) do
        [
          instance_double(
            YARD::Tags::VisibilityDirective,
            tag: YARD::Tags::Tag.new(:visibility, 'private')
          )
        ]
      end

      it { is_expected.to be true }
    end

    context 'when method has private visibility in Ruby but @api public in docs' do
      let(:tags) { [YARD::Tags::Tag.new(:api, 'public')] }
      let(:private_node) { instance_double(RuboCop::AST::SendNode, method_name: :private) }

      before do
        allow(source_node).to receive(:each_ancestor).with(:send).and_return([private_node])
      end

      it { is_expected.to be false }
    end
  end

  describe '#raises?' do
    subject(:raises?) { node.raises? }

    let(:method_nodes_enumerator) { method_nodes.each }

    before do
      allow(source_node).to receive(:each_descendant)
        .with(:send)
        .and_return(method_nodes_enumerator)
    end

    context 'when method has a raise statement' do
      let(:method_nodes) do
        [instance_double(RuboCop::AST::DefNode, method_name: :raise)]
      end

      it { is_expected.to be true }
    end

    context 'when method has a fail statement' do
      let(:method_nodes) do
        [instance_double(RuboCop::AST::DefNode, method_name: :fail)]
      end

      it { is_expected.to be true }
    end

    context 'when method has no raise or fail statements' do
      let(:method_nodes) do
        [instance_double(RuboCop::AST::DefNode, method_name: :something_else)]
      end

      it { is_expected.to be false }
    end

    context 'when method has no send nodes' do
      let(:method_nodes) { [] }

      it { is_expected.to be false }
    end
  end

  describe '#yields?' do
    subject(:yields?) { node.yields? }

    let(:nodes_enumerator) { nodes.each }

    before do
      allow(source_node).to receive(:each_descendant)
        .with(:yield)
        .and_return(nodes_enumerator)
    end

    context 'when method has yield statement' do
      let(:nodes) { [:yield] }

      it { is_expected.to be true }
    end

    context 'when method has no yield' do
      let(:nodes) { [] }

      it { is_expected.to be false }
    end
  end
end
