class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.528"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.528/octo-code-0.1.528-aarch64-apple-darwin.tar.gz"
  sha256 "0364f65328767880cbe45e95331a6940c43f01c5711ff13ee21d12bfb71c639a"

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
