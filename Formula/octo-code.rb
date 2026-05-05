class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.569"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.569/octo-code-0.1.569-aarch64-apple-darwin.tar.gz"
  sha256 "82cfe0e7c9303c4a27230e7c9f6e068be6de90b5a62826c9a657feb93db1952e"

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
