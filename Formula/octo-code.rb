class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.2"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.2/octo-code-0.1.2-aarch64-apple-darwin.tar.gz"
  sha256 "34b1f3302f9f7acd1722d6e1fb66ddfb7cb47cb0539cbd056a04b9381f0e378d"

  def install
    bin.install "octo-code"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
