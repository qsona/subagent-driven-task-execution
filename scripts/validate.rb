#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
REQUIRED = %w[
  README.md
  LICENSE
  THIRD_PARTY_NOTICES.md
  .gitignore
  SKILL.md
  agents/openai.yaml
].freeze

errors = []

REQUIRED.each do |path|
  errors << "missing required file: #{path}" unless File.file?(File.join(ROOT, path))
end

skill_path = File.join(ROOT, "SKILL.md")
if File.file?(skill_path)
  skill = File.read(skill_path, encoding: "UTF-8")
  match = skill.match(/\A---\n(.*?)\n---\n/m)
  if match
    begin
      frontmatter = YAML.safe_load(match[1], aliases: false)
      errors << "SKILL.md frontmatter name is invalid" unless frontmatter["name"] == "subagent-driven-task-execution"
      description = frontmatter["description"]
      errors << "SKILL.md frontmatter description is missing" unless description.is_a?(String) && !description.empty?
      if description.is_a?(String)
        required_description_phrases = [
          "トップレベルセッション",
          "Claude Fable 以外のモデルでは自動起動しない",
          "明示指定した場合はモデルを問わず使用する"
        ]
        missing_phrases = required_description_phrases.reject { |phrase| description.include?(phrase) }
        unless missing_phrases.empty?
          errors << "SKILL.md description is missing invocation policy phrases: #{missing_phrases.join(', ')}"
        end
      end
    rescue Psych::SyntaxError => e
      errors << "SKILL.md frontmatter is invalid YAML: #{e.message.lines.first.strip}"
    end
  else
    errors << "SKILL.md must begin with YAML frontmatter"
  end
end

metadata_path = File.join(ROOT, "agents/openai.yaml")
if File.file?(metadata_path)
  begin
    metadata = YAML.safe_load(File.read(metadata_path, encoding: "UTF-8"), aliases: false)
    errors << "agents/openai.yaml interface is missing" unless metadata["interface"].is_a?(Hash)
    implicit = metadata.dig("policy", "allow_implicit_invocation")
    errors << "agents/openai.yaml must disable implicit invocation for Codex" unless implicit == false
  rescue Psych::SyntaxError => e
    errors << "agents/openai.yaml is invalid YAML: #{e.message.lines.first.strip}"
  end
end

all_files = Dir.chdir(ROOT) do
  Dir.glob("**/*", File::FNM_DOTMATCH).reject do |path|
    File.directory?(path) || path == "." || path.start_with?(".git/")
  end
end

ignored_local = all_files.select do |path|
  File.basename(path) == ".DS_Store" || path.end_with?(".zip", ".zip.sha256") ||
    path == "dist" || path.start_with?("dist/")
end

in_git = system("git", "-C", ROOT, "rev-parse", "--is-inside-work-tree", out: File::NULL, err: File::NULL)
tracked = if in_git
            IO.popen(["git", "-C", ROOT, "ls-files", "-z"], "rb", &:read).split("\0")
          else
            all_files - ignored_local
          end

extra_files = ENV.fetch("VALIDATE_EXTRA_FILES", "").split(File::PATH_SEPARATOR).reject(&:empty?)

unwanted = tracked.select { |path| File.basename(path) == ".DS_Store" || path.end_with?(".zip", ".zip.sha256") }
errors << "unwanted tracked/generated files: #{unwanted.join(', ')}" unless unwanted.empty?

secret_patterns = {
  "private key" => /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  "GitHub token" => /\bgh[pousr]_[A-Za-z0-9]{20,}\b/,
  "AWS access key" => /\bAKIA[0-9A-Z]{16}\b/,
  "generic assigned secret" => /\b(?:api[_-]?key|secret|password|access[_-]?token)\s*[:=]\s*["'][^"']{8,}["']/i
}.freeze

scan_targets = tracked.map { |relative| [relative, File.join(ROOT, relative)] }
extra_files.each { |path| scan_targets << ["extra:#{path}", path] }

scan_targets.each do |relative, path|
  next unless File.file?(path)

  content = File.read(path, mode: "rb")
  next unless content.valid_encoding?

  secret_patterns.each do |label, pattern|
    errors << "possible #{label} in #{relative}" if content.match?(pattern)
  end
end

if errors.empty?
  puts "Validation passed."
  unless ignored_local.empty?
    puts "Ignored local artifacts (not distribution/tracking candidates):"
    ignored_local.sort.each { |path| puts "  - #{path}" }
  end
else
  warn errors.map { |error| "ERROR: #{error}" }.join("\n")
  exit 1
end
