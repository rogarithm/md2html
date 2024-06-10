RSpec::Matchers.define :eq_token do |expected_token|
  match do |actual_token|
    actual_token.type == expected_token.type &&
      actual_token.value == expected_token.value
  end

  failure_message do |actual_token|
    "expected token is not same as actual token!"
  end
end

RSpec::Matchers.define :eq_token_list do |expected_token_list|
  match do |actual_token_list|
    actual_token_list.tokens.each.with_index do |actual_token, index|
      expected_token = expected_token_list.tokens[index]
      expect(actual_token).to eq_token(expected_token)
    end
  end

  failure_message do |actual_token_list|
    msg = "expected token list is not same as actual token list!
    actual_token_list has length of #{actual_token_list.size}
    and actual_token_list's value was
    "
    actual_token_list.tokens.each do |token|
      msg += "type: >#{token.type}<, value: >#{token.value}<\n"
    end
    msg
  end
end
