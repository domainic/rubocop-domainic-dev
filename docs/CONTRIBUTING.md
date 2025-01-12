# Contributing to Domainic

Thank you for your interest in contributing to Domainic! We're building a suite of Ruby gems to empower developers with
domain-driven design tools. Before contributing, please review our [Development Guide](./../README.md#development) for
essential setup and CLI usage information.

## Table of Contents

* [Code of Conduct](#code-of-conduct)
* [Development Guidelines](#development-guidelines)
  * [Code Style](#code-style)
  * [Documentation](#documentation)
  * [Testing](#testing)
* [Making Changes](#making-changes)
  * [Branches](#branches)
  * [Commits](#commits)
  * [Pull Requests](#pull-requests)

## Code of Conduct

All contributors are expected to read and follow our [Code of Conduct](./CODE_OF_CONDUCT.md) before participating.

## Development Guidelines

### Code Style

We use RuboCop to enforce consistent code style throughout the project. Please ensure your changes pass the linting
checks by running `bundle exec rubocop` before submitting a PR. Our complete RuboCop configuration can be found in our
[rubocop config](./../.rubocop.yml).

### Testing

We use RSpec for testing. Key guidelines:

1. Use "is expected to" format for readability in test output:

  ```ruby
  # Good - produces clear output with --format documentation
  it { is_expected.to be_valid }

  # Also good - when example values shouldn't appear in output
  it 'is expected to have correct attributes' do
    expect(subject.name).to eq('example')
  end
```

2. Test Guidelines:
* Test behavior, not implementation
* One expectation per test
* Use descriptive contexts starting with "when", "with", or "without"
* Limit to 5 memoized helpers per context

## Making Changes

### Pull Requests

Before submitting a PR:

1. Run `bundle exec rspec` to ensure all tests and checks pass
2. Update documentation as needed
3. Include in your PR:
* Clear title and description
* Reference to related issues
* List of significant changes
* Screenshots for UI changes

## For Questions

* Open an issue for bugs or feature requests
* Join our discussions for general questions
* Contact maintainers for sensitive issues
