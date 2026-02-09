class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.90"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.90/octo-code-0.1.90-aarch64-apple-darwin.tar.gz"
  sha256 "f4ec4fdb666d851762a815f2d1db5deeb2fea7634f6ff6ed98e73e487f0e6d17"

  def install
    bin.install "octo-code"
    bin.install "octo-code-voice-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
