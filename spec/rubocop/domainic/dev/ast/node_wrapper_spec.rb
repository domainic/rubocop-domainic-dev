# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Domainic::Dev::AST::NodeWrapper do
  let(:processed_source) { instance_double(RuboCop::AST::ProcessedSource) }
  let(:source_node) { instance_double(RuboCop::AST::Node) }
  let(:node) { described_class.new(processed_source, source_node) }

  describe '.new' do
    subject(:new_node) { node }

    it 'is expected to create a new instance' do
      expect(new_node).to be_a(described_class)
    end
  end

  describe '#yard_docstring' do
    subject(:yard_docstring) { node.yard_docstring }

    let(:comments) { ['# My docstring', '# @api private'] }
    let(:comment_nodes) do
      comments.map do |c|
        instance_double(Parser::Source::Comment, text: c)
      end
    end

    before do
      allow(processed_source).to receive(:ast_with_comments).and_return({ source_node => comment_nodes })
    end

    it 'is expected to return a parsed YARD docstring' do
      expect(yard_docstring).to be_a(YARD::DocstringParser)
    end

    it 'is expected to parse the docstring text' do
      expect(yard_docstring.to_docstring.all).to eq("My docstring\n@api private")
    end

    it 'is expected to parse tags' do
      api_tag = yard_docstring.tags.find { |tag| tag.tag_name == 'api' }
      expect(api_tag.text).to eq('private')
    end

    context 'when there is an error parsing the docstring' do
      before do
        allow(YARD::DocstringParser).to receive(:new)
          .and_raise(StandardError)
      end

      it 'is expected to return nil' do
        expect(yard_docstring).to be_nil
      end
    end
  end

  describe 'method delegation' do
    context 'when method exists on source node' do
      let(:source_node) do
        instance_double(RuboCop::AST::Node, type: :def)
      end

      it 'is expected to delegate to source_node' do
        expect(node.type).to eq(:def)
      end
    end

    context 'when method does not exist' do
      it 'is expected to raise NoMethodError' do
        expect { node.undefined_method }.to raise_error(NoMethodError)
      end
    end
  end
end
