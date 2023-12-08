SNAFU_DIGITS = {
  "2" => 2,
  "1" => 1,
  "0" => 0,
  "-" => -1,
  "=" => -2,
}

class Snafu < String
  def to_i
    self.chars.reverse.map.with_index do |digit, place|
      SNAFU_DIGITS[digit] * (5 ** place)
    end.sum
  end
end

class Integer
  def to_snafu
    target = self
    cur_snafu = ""
    cur_value = 0
    Math::log(target, 5).ceil.downto(0).each do |place|
      digit = [-2, -1, 0, 1, 2].min_by { |digit| (cur_value + digit * (5**place) - target).abs }
      cur_value += digit * (5**place)
      cur_snafu += SNAFU_DIGITS.key(digit)
    end
    cur_snafu = cur_snafu.sub(/^0+/, "")
    cur_snafu = "0" if cur_snafu.empty?
    Snafu.new(cur_snafu)
  end
end

#puts File.readlines("input").map { |line| Snafu.new(line.chomp).to_i }.sum.to_snafu
sum = File.readlines("input").map { |line| Snafu.new(line.chomp).to_i }.sum
p sum
snafu = sum.to_snafu
p snafu.to_i
puts snafu

