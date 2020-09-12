#!/usr/bin/env ruby
# require 'awesome_print'
require 'fileutils'
require 'optparse'
require 'date'
require 'yaml'

@starting = Time.now
@github_repository = "test"

puts "Parsing options"
OptionParser.new do |parser|
 parser.on('-o', '--offset=TIME') do |time|
   offset = time.delete('^0-9:+-')
   @starting = @starting.getlocal(offset)
   puts ".. Applying UTC Offset: '#{offset}' #{@starting}"
 end
 parser.on('-r', '--repo=REPO') do |repo|
   @github_repository = repo
   puts ".. Applying '#{@github_repository}' repository"
 end
end.parse!

@templates_dir     = "/usr/local/bin/"
wc_file = '.verkilo/wordcount.yml'

@today             = @starting.strftime("%F")

def getBuildFilename(src, ext)
  dst = [
    File.basename((@github_repository.nil?) ? Dir.pwd : @github_repository),
    File.basename(src),
    @today
  ].join('-') + ".#{ext}"
  File.join(["build", dst])
end

history = if File.exist?(wc_file)
  f = File.open(wc_file)
  x = f.read()
  f.close
  YAML.load(x)
else
  {}
end
history[@today] = {} if history[@today].nil?
# ap history
FileUtils.mkdir_p("build/")
puts "Calculating wordcount"
Dir["**/.book"].each do |target|
  target = File.dirname(target)
  book = File.basename(target)

  # Combine into one file for consistency & debugging
  src = getBuildFilename(target, "src.md")
  t = Dir["./#{target}/**/*.md"].sort.map { |f| File.open(f,'r').read }.join("\n")
  f = File.open(src,'w')
  f.write(t)
  f.close()

  # Wordcount ala pandoc
  cmd = "pandoc --lua-filter #{@templates_dir}wordcount.lua -o /tmp/wc.md #{src}"
  x = `#{cmd}`
  puts "..'#{book}': #{x.to_i}"
  history[@today][book] = x.to_i
end
history[@today]['total'] = history[@today].map{|k,v| v}.inject(0, :+)

# Write to local file
f = File.open(wc_file, 'w')
f.write(YAML.dump(history))
f.close
