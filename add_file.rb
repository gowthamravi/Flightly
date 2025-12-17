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

# Logic to find/create group structure
# Example: "FlightSearch/Auth/LoginView.swift"
# Group path: ["FlightSearch", "Auth"]
# File name: "LoginView.swift"

# We assume the file_path is relative to the project root
path = Pathname.new(file_path_str)
path_components = path.each_filename.to_a
file_name = path_components.pop
dir_components = path_components

# Start from main group (root)
current_group = project.main_group

dir_components.each do |component|
  # Skip "." or empty components
  next if component == "." || component.empty?
  
  # Find existing child group or create new one
  # .find_subpath is better but .[] is simpler for direct children
  next_group = current_group[component]
  
  if next_group.nil?
    # Create new group
    # We use 'new_group' without path, assuming it matches the folder name
    # But for 'new_file' to work relative to it, setting path is often safer if it exists on disk
    next_group = current_group.new_group(component)
  end
  current_group = next_group
end

# Check if file ref already exists to avoid duplicates
existing_ref = current_group.files.find { |f| f.path == file_name }

if existing_ref
  # Ensure it is in the target
  unless target.source_build_phase.files_references.include?(existing_ref)
    target.add_file_references([existing_ref])
    puts "🔹 Added existing ref #{file_name} to target"
  end
  puts "✅ File #{file_name} already exists in group."
else
  # Create file reference in the last group
  file_ref = current_group.new_file(file_name)
  target.add_file_references([file_ref])
  puts "✅ Added #{file_name} to group '#{current_group.path || current_group.name}' and target '#{target.name}'"
end

project.save
