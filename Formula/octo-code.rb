class OctoCode < Formula
  desc "Voice-driven multi-agent development environment"
  homepage "https://github.com/OASans/homebrew-octo-code-release"
  version "0.1.738"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "tmux"
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/OASans/homebrew-octo-code-release/releases/download/v0.1.738/octo-code-0.1.738-aarch64-apple-darwin.tar.gz"
  sha256 "729351307b0dcf77b3e66e3f5fa43eda2790c86b6c2d233397b26641f7f5811c"

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
