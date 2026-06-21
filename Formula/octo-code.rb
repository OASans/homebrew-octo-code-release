class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.711"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on "terminal-notifier"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.711/octo-code-0.1.711-aarch64-apple-darwin.tar.gz"
  sha256 "bac8f2aff90ed8a534b43d72137995566ce80c4edca7bbe214073ecd19431f45"

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
