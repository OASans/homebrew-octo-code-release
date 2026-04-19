class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.514"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.514/octo-code-0.1.514-aarch64-apple-darwin.tar.gz"
  sha256 "a71ede87659bf04fa57f70e9ea0f78cf7670aa0a9ac87f66e2f06223cdcc45f8"

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
