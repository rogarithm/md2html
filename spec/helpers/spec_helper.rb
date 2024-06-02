# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require_relative './file_helper'

RSpec.configure do |config|
  config.include FileHelper

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  def align_node actual_node, expected_node
    lefts = ["ACTUAL", actual_node.type, actual_node.value, actual_node.consumed.to_s]
    rights = ["EXPECTED", expected_node.type, expected_node.value, expected_node.consumed.to_s]

    longest_attr = lefts.max { |a,b| a.length <=> b.length }
    max_length = longest_attr.length

    result = ''
    lefts.each.with_index do |left, index|
      result += "#{right_align_attr(left, max_length)} | #{rights[index]}\n"
    end
    result
  end

  def right_align_attr attr, max_length
    "#{' ' * (max_length - attr.length)}#{attr}"
  end

  RSpec::Matchers.define :eq_node do |expected_node|
    match do |actual_node|
      actual_node.type == expected_node.type &&
        actual_node.value == expected_node.value &&
        actual_node.consumed == expected_node.consumed
    end
    failure_message do |actual_node|
      "Expected that actual_node would have all the attributes the same as expected_node.\n
Attributes:\n
#{align_node actual_node, expected_node}\n"
    end
  end

  RSpec::Matchers.define :eq_list_node do |expected_node|
    match do |actual_node|
      actual_node.sentences.each.with_index do |sentence, index|
        sentence.to.eq_node expected_node.sentences[index]
      end
    end
    match do |actual_node|
      actual_node.consumed == expected_node.consumed
    end
    match do |actual_node|
      actual_node.type == expected_node.type
    end
    failure_message do |actual_node|
      "expected that #{actual_node} would have all the attributes the same as #{expected_node}. Attributes:\n
      ACTUAL | EXPECTED\n
      #{actual_node.sentences} | #{expected_node.sentences}\n
      #{actual_node.consumed} | #{expected_node.consumed}\n
      #{actual_node.type} | #{expected_node.type}\n"
    end
  end

  RSpec::Matchers.define :eq_sentence_node do |expected_node|
    match do |actual_node|
      actual_node.words.each.with_index do |word, index|
        word.to.eq_node expected_node.words[index]
      end
    end
    match do |actual_node|
      actual_node.consumed == expected_node.consumed
    end
    failure_message do |actual_node|
      "expected that #{actual_node} would have all the attributes the same as #{expected_node}. Attributes:\n
      ACTUAL | EXPECTED\n
      #{actual_node.words} | #{expected_node.words}\n
      #{actual_node.consumed} | #{expected_node.consumed}\n"
    end
  end

  RSpec::Matchers.define :eq_paragraph_node do |expected_node|
    match do |actual_node|
      actual_node.sentences.each.with_index do |sentence, index|
        sentence.to.eq_sentence_node expected_node.sentences[index]
      end
    end
    match do |actual_node|
      actual_node.sentences.size == expected_node.sentences.size
      actual_node.consumed == expected_node.consumed
    end
    failure_message do |actual_node|
      "expected that #{actual_node} would have all the attributes the same as #{expected_node}. Attributes:\n
      ACTUAL | EXPECTED\n
      #{actual_node.sentences} | #{expected_node.sentences}\n
      #{actual_node.consumed} | #{expected_node.consumed}\n"
    end
  end

  RSpec::Matchers.define :eq_body_node do |expected_node|
    match do |actual_node|
      actual_node.blocks.each.with_index do |block, index|
        if block.type == 'PARAGRAPH'
          block.to.eq_paragraph_node expected_node.block[index]
          next
        end
        if block.type == 'LIST'
          block.to.eq_list_node expected_node.block[index]
          next
        end
      end
    end
    match do |actual_node|
      actual_node.blocks.size == expected_node.blocks.size
      actual_node.consumed == expected_node.consumed
    end
    failure_message do |actual_node|
      "expected that #{actual_node} would have all the attributes the same as #{expected_node}. Attributes:\n
      ACTUAL | EXPECTED\n
      #{actual_node.blocks} | #{expected_node.blocks}\n
      #{actual_node.consumed} | #{expected_node.consumed}\n"
    end
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
