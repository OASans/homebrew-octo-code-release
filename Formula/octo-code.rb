class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.615"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "flock"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.615/octo-code-0.1.615-aarch64-apple-darwin.tar.gz"
  sha256 "572c6a93366d3c6785db6fccb1b869b69e36d519fb05a22f5c196eed7ab34723"

  def install
    bin.install "octo-code"
    bin.install "octo-code-daemon"
    bin.install "octo-code-ui"
    bin.install_symlink "octo-code" => "oc"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
