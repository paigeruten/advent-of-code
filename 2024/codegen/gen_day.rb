require 'fileutils'

TEMPLATE_PATH = "#{__dir__}/day_template.rs"
SRC_PATH = "#{__dir__}/../src"
INPUT_PATH = "#{__dir__}/../input"
DAYS_PATH = "#{SRC_PATH}/days.rs"

DAYS_TEMPLATE = <<-TEMPLATE
use std::io::BufRead;

use crate::common::{Part, Solution};

{{modules}}

pub const NUM_DAYS: usize = {{num_days}};

pub fn solve(day_number: usize, part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    match day_number {
{{match_arms}}
        _ => Err(color_eyre::eyre::eyre!("That day has not been solved yet.")),
    }
}
TEMPLATE

day_num = ARGV.first.to_i
day_num_padded = "%02d" % day_num

template = File.read(TEMPLATE_PATH)

content = template.gsub('{{day_num_padded}}', day_num_padded)
target_path = "#{SRC_PATH}/days/day#{day_num_padded}.rs"

FileUtils.touch("#{INPUT_PATH}/day#{day_num_padded}")
puts "\x1b[1mTouched\x1b[0m  input/day#{day_num_padded}"

if File.exist? target_path
  puts "Error: File '#{target_path}' already exists"
  exit 1
end

File.write(target_path, content)
puts "\x1b[1mCreated\x1b[0m  src/days/day#{day_num_padded}.rs"

existing_days = Dir["#{SRC_PATH}/days/day??.rs"].map do |path|
  File.basename(path, ".rs")[3..4]
end

num_days = existing_days.map(&:to_i).max
if existing_days.map(&:to_i).sort != (1..num_days).to_a
  puts "Error: Days do not consecutively increase from 1"
  exit 1
end

days_modules = existing_days.map { |day_num| "mod day#{day_num};"}.join("\n")
days_match_arms = existing_days.map do |day_num|
  "        #{day_num.to_i} => day#{day_num}::solve(part, input),"
end.join("\n")

days_content = DAYS_TEMPLATE
  .sub('{{num_days}}', existing_days.map(&:to_i).max.to_s)
  .sub('{{modules}}', days_modules)
  .sub('{{match_arms}}', days_match_arms)

File.write(DAYS_PATH, days_content)
puts "\x1b[1mUpdated\x1b[0m  src/days.rs"

