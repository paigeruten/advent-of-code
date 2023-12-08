class Directory
  attr_reader :subdirs, :files

  def initialize
    @subdirs = {}
    @files = {}
  end

  def add_subdir(name)
    @subdirs[name] = Directory.new
    self
  end

  def add_file(name, size)
    @files[name] = size
    self
  end

  def total_size
    @files.values.sum + @subdirs.values.map(&:total_size).sum
  end

  def each_dir
    yield self
    @subdirs.each do |_, subdir|
      subdir.each_dir do |subsubdir|
        yield subsubdir
      end
    end
  end

  def all_dirs
    dirs = []
    each_dir { |dir| dirs.push dir }
    dirs
  end

  def to_s(level = 0)
    indent = "  " * level

    lines = []
    @files.each do |name, size|
      lines.push "#{indent}#{name} (#{size} bytes)"
    end
    @subdirs.each do |name, subdir|
      lines.push "#{indent}#{name}/"
      lines.push subdir.to_s(level + 1)
    end
    lines.join("\n")
  end
end

root = Directory.new
cwd = [root]

is_listing_dir = false
File.readlines("input").map(&:chomp).each do |line|
  is_listing_dir = false if line.start_with? "$"

  if line.start_with? "$ cd "
    subdir_name = line[5..]
    case subdir_name
    when "/"
      cwd = [root]
    when ".."
      cwd.pop
    else
      cwd.push cwd.last.subdirs.fetch(subdir_name)
    end
  elsif line == "$ ls"
    is_listing_dir = true
  elsif is_listing_dir && line =~ /^dir (\w+)$/
    cwd.last.add_subdir($1)
  elsif is_listing_dir && line =~ /^(\d+) ([a-z.]+)$/
    cwd.last.add_file($2, $1.to_i)
  else
    raise "Unexpected line!"
  end
end

total_size_less_than_100k =
  root.all_dirs.map(&:total_size).select { |size| size < 100_000 }.sum

TOTAL_DISK_SPACE = 70_000_000
UNUSED_SPACE_NEEDED = 30_000_000

current_unused_space = TOTAL_DISK_SPACE - root.total_size
extra_space_needed = UNUSED_SPACE_NEEDED - current_unused_space

size_of_directory_to_delete =
  root.all_dirs.map(&:total_size).sort.detect { |size| size >= extra_space_needed }

puts "Part 1: #{total_size_less_than_100k}"
puts "Part 2: #{size_of_directory_to_delete}"
