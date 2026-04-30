class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.552"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.552/octo-code-0.1.552-aarch64-apple-darwin.tar.gz"
  sha256 "d490acb00f82dceac8be689c0fb0c2a613afe7a2d29b26b7c70577ce760d27ed"

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
