class InstallerScript < Formula
  desc "A script to set up my environment"
  homepage "https://github.com/professoruix/installer"
  url "https://github.com/professoruix/installer/blob/main/installer.sh" # or the direct URL to your script
  sha256 "faebeb8da80ca8184c42294cf6f02bfdfd9fec510c6cff910ffaa75a9836a2d6" # the SHA-256 of the tarball or script

  def install
    bin.install "installer.sh" => "my-installer"
  end

  def caveats
    <<~EOS
      You have installed the installer script.
      To run it, execute the following command:
          my-installer
    EOS
  end

  test do

  end
end
