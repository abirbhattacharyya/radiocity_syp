module ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  $content_class = nil
  
  def rand_code(limit)
    chars = ("a".."z").to_a
    nums = ("0".."9").to_a
    str = chars + nums
    ary1 = []
    ary1 << chars[rand(999)%chars.length]
    (2..limit).each { |i| ary1 << str[rand(999)%str.length] }
    return ary1*""
  end

  def plural(num, text)
    pluralize(num, text)
  end

  def with_precision(number, options = {})
    return number_with_precision(number, options)
  end
end
