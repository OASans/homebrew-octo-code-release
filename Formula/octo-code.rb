class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.721"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on "terminal-notifier"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.721/octo-code-0.1.721-aarch64-apple-darwin.tar.gz"
  sha256 "205f5a698704ad8bb0358c6dd37e0dce6782de6415b04c90598a895c2c1bfccf"

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
