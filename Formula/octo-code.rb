class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.32"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.32/octo-code-0.1.32-aarch64-apple-darwin.tar.gz"
  sha256 "b5ffefa74e891db165f394c17c70f3bc4a305d5902fd16aaf0e248151a448820"

  def install
    bin.install "octo-code"
    bin.install "octo-code-voice-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
