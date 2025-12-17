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

path = Pathname.new(file_path_str)
file_name = path.basename.to_s
dir_components = path.dirname.each_filename.to_a

# Start from main group
current_group = project.main_group

dir_components.each do |component|
  next if component == "." || component.empty?
  
  # Find or create group
  next_group = current_group[component]
  
  if next_group.nil?
    next_group = current_group.new_group(component, component) # name, path
    puts "📂 Created group '#{component}' with path '#{component}'"
  else
    # If group exists but has no path, set it?
    # Be careful not to break existing virtual groups, but for our AI generated code
    # we expect folder structure to match.
    if next_group.path.nil?
      # Assuming it should map to folder since we found it by name matching a folder component
      next_group.set_path(component) 
      puts "🔧 Updated existing group '#{component}' path to '#{component}'"
    end
  end
  current_group = next_group
end

# Check if file ref exists
existing_ref = current_group.files.find { |f| f.path == file_name }

if existing_ref
  unless target.source_build_phase.files_references.include?(existing_ref)
    target.add_file_references([existing_ref])
    puts "🔹 Added existing ref #{file_name} to target"
  end
else
  # new_file(file_path) adds relative to group
  file_ref = current_group.new_file(file_name)
  target.add_file_references([file_ref])
  puts "✅ Added #{file_name} to group '#{current_group.name}'"
end

project.save
