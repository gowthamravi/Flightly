#!/usr/bin/env ruby
require 'xcodeproj'
require 'pathname'

# Usage: ruby add_file.rb <path_to_xcodeproj> <file_path> <target_name>
project_path = ARGV[0]
file_path_str = ARGV[1]
target_name = ARGV[2]

if project_path.nil? || file_path_str.nil?
  puts "Usage: ruby add_file.rb <project_path> <file_path> [target_name]"
  exit 1
end

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == target_name } || project.targets.first

if target.nil?
  puts "❌ Target '#{target_name}' not found."
  exit 1
end

# Resolve the file name and directory path
path = Pathname.new(file_path_str)
file_name = path.basename.to_s
dir_path = path.dirname.to_s

# Skip "." if it's just the filename
dir_path = nil if dir_path == "."

# Start from main group
# .find_subpath(path, true) recursively finds or creates the group hierarchy
# This handles "FlightSearch/Auth" correctly by finding existing groups first
if dir_path
  group = project.main_group.find_subpath(dir_path, true)
else
  group = project.main_group
end

# Check if file ref already exists in this group to avoid duplicates
existing_ref = group.files.find { |f| f.path == file_name }

if existing_ref
  # Ensure it is in the target
  unless target.source_build_phase.files_references.include?(existing_ref)
    target.add_file_references([existing_ref])
    puts "🔹 Added existing ref #{file_name} to target"
  end
  puts "✅ File #{file_name} already exists in group."
else
  # Create file reference in the group
  # IMPORTANT: new_file(path) sets the internal path properly relative to the group
  # passed to it. If the group corresponds to 'FlightSearch/Auth', calling
  # new_file('LoginView.swift') sets the path to 'LoginView.swift' relative to that group.
  file_ref = group.new_file(file_name)
  target.add_file_references([file_ref])
  puts "✅ Added #{file_name} to group '#{group.path || group.name}' and target '#{target.name}'"
end

project.save
