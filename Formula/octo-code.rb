class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.706"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on "terminal-notifier"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.706/octo-code-0.1.706-aarch64-apple-darwin.tar.gz"
  sha256 "fb3224688cf9a9173d738cec60e0e3bcfa4844c72b7e3f3dc6f10625978a79f0"

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
