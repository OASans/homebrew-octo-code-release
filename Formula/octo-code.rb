class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.319"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.319/octo-code-0.1.319-aarch64-apple-darwin.tar.gz"
  sha256 "ad25a39d3d5b185b83d1f0d0efadfbbcd610ab326fc9b2e0da0d3d96cc44550a"

  def install
    bin.install "octo-code"
    bin.install "octo-code-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
