class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.531"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.531/octo-code-0.1.531-aarch64-apple-darwin.tar.gz"
  sha256 "7003ab15576f9b712a5c3c5a1082a37648efa7d89ed3e6bb044da1224939087e"

  def install
    bin.install "oc"
    bin.install "octo-code"
    bin.install "octo-code-daemon"
    bin.install "octo-code-ui"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
