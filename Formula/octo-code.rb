class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.185"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.185/octo-code-0.1.185-aarch64-apple-darwin.tar.gz"
  sha256 "8e1d59519084818c16067e3b50820dc45d0b33ab505c0325a4e849503dc3f45e"

  def install
    bin.install "octo-code"
    bin.install "octo-code-voice-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
