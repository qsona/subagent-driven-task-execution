# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tempfile"

class ValidateSecretScanTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_known_dummy_secret_is_detected
    Tempfile.create("validate-secret-scan") do |file|
      file.write("example = #{"AK" + "IA1234567890ABCDEF"}\n")
      file.flush

      stdout, stderr, status = Open3.capture3(
        { "VALIDATE_EXTRA_FILES" => file.path },
        "ruby", File.join(ROOT, "scripts/validate.rb")
      )

      refute status.success?, stdout
      assert_includes stderr, "possible AWS access key"
    end
  end
end
