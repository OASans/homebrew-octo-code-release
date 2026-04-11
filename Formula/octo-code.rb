class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.478"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.478/octo-code-0.1.478-aarch64-apple-darwin.tar.gz"
  sha256 "520e129db9182c43d09de0ffa7ee074bab33a0443cc098a4e3a456d9146e4c3c"

  def install
    bin.install "oc"
    bin.install "octo-code"
    bin.install "octo-code-daemon"
    bin.install "octo-code-ui"
    bin.install "octo-code-agent"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
