class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.206"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.206/octo-code-0.1.206-aarch64-apple-darwin.tar.gz"
  sha256 "e46c5b3fb34f741c794e263294c326903290b60974ebb7333faca0ea388e9074"

  def install
    bin.install "octo-code"
    bin.install "octo-code-voice-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
