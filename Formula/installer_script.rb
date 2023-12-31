class InstallerScript < Formula
  desc "A script to set up my environment"
  homepage "https://github.com/professoruix/installer"
  url "https://raw.githubusercontent.com/professoruix/installer/main/installer.sh" # Direct link to the raw script
  sha256 "faebeb8da80ca8184c42294cf6f02bfdfd9fec510c6cff910ffaa75a9836a2d6"
  version "1.0.0"

  def install
    bin.install "installer.sh" => "installer_script"
  end

  def caveats
    <<~EOS
      You have installed the installer script.
      To run it, execute the following command:
          installer_script
    EOS
  end

  test do
   assert_predicate bin/"installer_script", :exist?
  system "#{bin}/installer_script", "--version"
  system "#{bin}/installer_script", "--help"
  end
end
