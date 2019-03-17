# yvm formula
class Yvm < Formula
  desc 'Yarn Version Manager'
  homepage 'https://yvm.js.org'
  # Should only be updated if the new version is listed as a stable release
  url 'https://github.com/tophat/yvm/archive/v2.4.1.tar.gz'

  bottle :unneeded

  depends_on 'node' => :recommended
  depends_on 'unzip' => :build
  depends_on 'curl' => :build

  conflicts_with 'hadoop', because: 'both install `yarn` binaries'
  conflicts_with 'yarn', because: 'yvm installs and manages yarn'

  def install
    system 'make', 'install'
  end

  test do
    system bin / 'bash -l -c "yvm --version"'
  end
end
