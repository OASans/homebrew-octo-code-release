class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.6"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.6/octo-code-0.1.6-aarch64-apple-darwin.tar.gz"
  sha256 "added7ef245c92377d579eeef4ebbc38c98806267729a58e46a8af87d8a6a76e"

  def install
    bin.install "octo-code"
    bin.install "octo-code-voice-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
