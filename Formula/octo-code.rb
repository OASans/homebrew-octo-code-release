class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.714"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on "terminal-notifier"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.714/octo-code-0.1.714-aarch64-apple-darwin.tar.gz"
  sha256 "b809e8d9ed4bf6643aede0ab4961d8020f54dbe3ed305f0623b4d62e7e4ba56e"

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
