class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.320"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.320/octo-code-0.1.320-aarch64-apple-darwin.tar.gz"
  sha256 "564bc042f7af10b36df93e36b6eb8863a499b287e800c57f5b7219930cf09630"

  def install
    bin.install "octo-code"
    bin.install "octo-code-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
