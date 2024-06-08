def format_attr_info_msg left, right, max_length
  "#{left}#{' ' * (max_length - left.length)} | #{right}\n"
end

def collect_node_info actual_node, expected_node, is_inner
  attr_names = actual_node.instance_variables.inject([]) {|result, attr_name| result << attr_name.to_s.sub(/@/,'')}

  node_info =  [["ACTUAL", "EXPECTED"]]
  if is_inner == true
    node_info = []
  end

  attr_names.each do |attr_name|
    current_attr = attr_name.to_sym

    if current_attr == :sentences or current_attr == :blocks
      actual_inner_nodes = actual_node.send(current_attr)
      expected_inner_nodes = expected_node.send(current_attr)

      actual_inner_nodes.each.with_index do |actual_inner_node, index|
        collect_node_info(actual_inner_node, expected_inner_nodes[index], true).each do |pair|
          node_info << pair
        end
      end
    else
      left = actual_node.send(current_attr).to_s
      right = expected_node.send(current_attr).to_s
      if is_inner == true
        left = " " + left
        right = " " + right
      end
      node_info << [left, right]
    end
  end

  node_info
end

def generate_node_info_msg_body info_obj
  pairs = info_obj

  longest_attr_pair = pairs.max { |a,b| a[0].length <=> b[0].length }
  max_length = longest_attr_pair[0].length

  result = ""
  pairs.each do |pair|
    left = pair[0]
    right = pair[1]
    result += "#{format_attr_info_msg(left, right, max_length)}"
  end
  result
end

def generate_node_info_msg actual_node, expected_node
  result = "Expected that actual node would have all the attributes the same as expected node.\n
Attributes:\n\n"
  info_obj = collect_node_info actual_node, expected_node, false
  result += generate_node_info_msg_body info_obj
  result
end

RSpec::Matchers.define :eq_node do |expected_node|
  match do |actual_node|
    actual_node.type == expected_node.type &&
      actual_node.value == expected_node.value &&
      actual_node.consumed == expected_node.consumed
  end
  failure_message do |actual_node|
    "#{generate_node_info_msg actual_node, expected_node}\n"
  end
end

RSpec::Matchers.define :eq_list_node do |expected_node|
  match do |actual_node|
    actual_node.sentences.each.with_index do |sentence, index|
      sentence.to.eq_node expected_node.sentences[index]
    end
  end
  match do |actual_node|
    actual_node.type == expected_node.type &&
      actual_node.consumed == expected_node.consumed
  end

  failure_message do |actual_node|
    "#{generate_node_info_msg actual_node, expected_node}\n"
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
    "#{generate_node_info_msg actual_node, expected_node}\n"
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
    "#{generate_node_info_msg actual_node, expected_node}\n"
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
    "#{generate_node_info_msg actual_node, expected_node}\n"
  end
end


