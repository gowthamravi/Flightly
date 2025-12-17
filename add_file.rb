#!/usr/bin/env ruby
require 'xcodeproj'

# Usage: ruby add_file.rb <path_to_xcodeproj> <file_path> <target_name>
project_path = ARGV[0]
file_path = ARGV[1]
target_name = ARGV[2]

if project_path.nil? || file_path.nil?
  puts "Usage: ruby add_file.rb <project_path> <file_path> [target_name]"
  exit 1
end

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == target_name } || project.targets.first

if target.nil?
  puts "❌ Target '#{target_name}' not found."
  exit 1
end

# Create a group structure if needed, or just add to root group for now
# For simplicity, we add to the main group
group = project.main_group
file_ref = group.new_file(file_path)

# Add to target
target.add_file_references([file_ref])

project.save
puts "✅ Added #{file_path} to target '#{target.name}'"
