class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.3"
  license "MIT"

  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.3/octo-code-0.1.3-aarch64-apple-darwin.tar.gz"
  sha256 "13e42860d07a6280ed39ff8ce60b70dfc4141de4e12c44ce05bbc3f274c40505"

  def install
    bin.install "octo-code"
  end

  test do
    system "#{bin}/octo-code", "--version"
  end
end
