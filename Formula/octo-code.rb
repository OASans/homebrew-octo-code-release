class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.0"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.0/octo-code-0.1.0-aarch64-apple-darwin.tar.gz"
  sha256 "4e554c49113d369cfe3c1720c5cb98ea38a6e344da8dc65b66dc513c21a60613"

  def install
    bin.install "octo-code"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
