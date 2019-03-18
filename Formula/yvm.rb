# Yarn Version Manager
class Yvm < Formula
  desc 'Manage multiple versions of Yarn'
  homepage 'https://yvm.js.org'
  # Should only be updated if the new version is listed as a stable release
  url 'https://github.com/tophat/yvm/releases/download/v2.4.1/yvm.zip'
  sha256 '82e0e3ee1e66ad389641fef9d9c3a164124cd63e89323a77e03a30fa9d5ecfdf'

  bottle :unneeded

  depends_on 'node' => %i[recommended optional] # Ignore if node already managed
  depends_on 'unzip' => %i[build optional] # Ignore if unzip already installed
  depends_on 'curl' => %i[build optional] # Ignore if curl already installed

  conflicts_with 'hadoop', because: 'both install `yarn` binaries'
  conflicts_with 'yarn', because: 'yvm installs and manages yarn'

  def install
    chmod 755, 'yvm.sh'
    inreplace ['yvm.sh', 'yvm.fish'], 'curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.sh | YVM_INSTALL_DIR=${YVM_DIR} bash', 'echo "Yvm update-self disabled. Installed via homebrew."'
    cp 'yvm.sh', bin / 'yvm'
    prefix.install Dir['*']
  end

  def post_install
    echo '~~~ Caveats ~~~'
    echo 'Add this to your ~/.bashrc or ~/.zsh'
    echo "export YVM_DIR=#{prefix}"
    echo '[ -r $YVM_DIR/yvm.sh ] && source $YVM_DIR/yvm.sh'
    echo 'And for you fishers to your ~/.config/fish/config.fish'
    echo "set -x YVM_DIR #{prefix}"
    echo 'source . $YVM_DIR/yvm.fish'
  end

  test do
    system 'bash -l -c "yvm --version"'
  end
end
