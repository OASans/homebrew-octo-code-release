class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.737"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.737/octo-code-0.1.737-aarch64-apple-darwin.tar.gz"
  sha256 "d2a8cb303140d1f5a976772b8111265f6beaaae378ca59296a2b47127046dcb9"

  def install
    bin.install "octo-code"
    bin.install "octo-code-daemon"
    bin.install "octo-code-ui"
    bin.install_symlink "octo-code" => "oc"
    lib.install "lib/octo-code"
    (share/"octo-code").install "licenses"
  end

  test do
    system "#{bin}/octo-code", "--help"
  end
end
