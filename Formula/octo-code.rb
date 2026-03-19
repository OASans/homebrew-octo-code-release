class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.321"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.321/octo-code-0.1.321-aarch64-apple-darwin.tar.gz"
  sha256 "11274d833da1a0ba1c9eb442cd01d8765643b0119162115c8588473748d4a448"

  def install
    bin.install "octo-code"
    bin.install "octo-code-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
