class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.520"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.520/octo-code-0.1.520-aarch64-apple-darwin.tar.gz"
  sha256 "59a3d80374dbe554e1866c865b447589c3488686c3973845d1d4b7886fe1a5a9"

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
