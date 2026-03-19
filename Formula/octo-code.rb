class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.320"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.320/octo-code-0.1.320-aarch64-apple-darwin.tar.gz"
  sha256 "313357d2dab40dadc9e07757889ca8bb89bd2c335ba3e6c8e13408a21e9ee3f2"

  def install
    bin.install "octo-code"
    bin.install "octo-code-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
