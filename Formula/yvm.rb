# yvm formula
class Yvm < Formula
  desc 'Yarn Version Manager'
  homepage 'https://yvm.js.org'
  # Should only be updated if the new version is listed as a stable release
  url 'https://github.com/tophat/yvm/archive/v2.4.1.tar.gz'

  bottle :unneeded

  depends_on 'node'
  depends_on 'unzip'
  depends_on 'curl'

  conflicts_with 'hadoop', because: 'both install `yarn` binaries'
  conflicts_with 'yarn', because: 'both install `yarn` binaries'

  def install
    system 'make', 'install'
  end

  test do
    system bin / 'bash -l -c "yvm --version"'
  end
end
