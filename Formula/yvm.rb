# yvm formula
class YVM < Formula
  desc 'Yarn Version Manager'
  homepage 'https://yvm.js.org'
  # Should only be updated if the new version is listed as a stable release
  url 'https://github.com/tophat/yvm/archive/v2.4.1.tar.gz'

  bottle :unneeded

  depends_on 'node', 'unzip', 'curl'

  conflicts_with 'hadoop', 'yarn', because: 'both install `yarn` binaries'

  def install
    system bin / 'curl -fsSL https://raw.githubusercontent.com/tophat/yvm/v2.4.1/scripts/install.sh | INSTALL_VERSION="v2.4.1" bash'
  end

  test do
    system bin / 'bash -l -c "yvm --version"'
  end
end
