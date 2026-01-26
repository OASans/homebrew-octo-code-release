class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.1"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.1/octo-code-0.1.1-aarch64-apple-darwin.tar.gz"
  sha256 "c4b1140eab5a1fbc72bf71a4336b7f4e16562c90afda10bfbabc0c5ea697f50d"

  def install
    bin.install "octo-code"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
