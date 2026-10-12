#!/usr/bin/env ruby
# Check HelloFresh recipe notes against the note format.
#
# Usage: verify_notes.rb VAULT_ROOT NOTE.md [NOTE.md ...]
# Prints "ok" or "BAD <problems>" per note; exits 1 if any note is bad.

require "yaml"

REQUIRED = %w[type title ingredients tags prep_time cook_time difficulty rating servings
              category calories protein notes origin source cover].freeze

vault = ARGV.shift
bad = 0
ARGV.each do |note|
  _, fm, body = File.read(note).split(/^---\n/, 3)
  probs = []
  begin
    y = YAML.load(fm.to_s) || {}
  rescue Psych::SyntaxError => e
    y = {}
    probs << "frontmatter YAML: #{e.message}"
  end
  missing = REQUIRED.reject { |k| y.key?(k) }
  probs << "missing #{missing.join(",")}" unless missing.empty?
  probs << "steps belong in the body, not frontmatter" if y.key?("steps")
  probs << "type is not recipe" unless y["type"] == "recipe"
  body = body.to_s
  probs << "no ## Steps section" unless body.include?("## Steps\n")
  sections = body.split(/^### /)[1..] || []
  probs << "no step sections" if sections.empty?
  probs << "step section without bullets" if sections.any? { |s| s !~ /^- \S/ }
  body.scan(/!\[\[([^\]|]+)/).flatten.each do |rel|
    path = File.join(vault, rel)
    probs << "missing image #{rel}" unless File.size?(path)
  end
  puts probs.empty? ? "ok  #{File.basename(note)}" : "BAD #{File.basename(note)}: #{probs.join("; ")}"
  bad += 1 unless probs.empty?
end
exit(bad.zero? ? 0 : 1)
