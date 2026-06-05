class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.697"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on "terminal-notifier"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.697/octo-code-0.1.697-aarch64-apple-darwin.tar.gz"
  sha256 "afadbc97567db6022a30a049d44b988c920bed57e23a98eec7e295f22445d558"

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
