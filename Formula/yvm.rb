# Yarn Version Manager
class Yvm < Formula
  desc 'Manage multiple versions of Yarn'
  homepage 'https://yvm.js.org'
  # Should only be updated if a newer version is listed as a stable release
  url 'https://github.com/tophat/yvm/releases/download/v2.4.1/yvm.zip'
  sha256 '82e0e3ee1e66ad389641fef9d9c3a164124cd63e89323a77e03a30fa9d5ecfdf'

  bottle :unneeded

  depends_on 'node' => %i[recommended optional] # Ignore if node already managed

  conflicts_with 'hadoop', because: 'both install `yarn` binaries'
  conflicts_with 'yarn', because: 'yvm installs and manages yarn'

  def install
    update_self_disabled = 'echo "Yvm update-self disabled. Installed via homebrew."'
    inreplace 'yvm.sh' do |s|
        s.gsub! 'YVM_DIR=${YVM_DIR-"${HOME}/.yvm"}', "YVM_DIR='#{prefix}'"
        s.gsub! 'curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.sh | YVM_INSTALL_DIR=${YVM_DIR} bash', update_self_disabled
    end
    inreplace 'yvm.fish' do |s|
        s.gsub! 'set -q YVM_DIR; or set -U YVM_DIR "$HOME/.yvm"', "set -U YVM_DIR '#{prefix}'"
        s.gsub! 'env YVM_INSTALL_DIR=$YVM_DIR curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.sh | bash', update_self_disabled
    end
    chmod 0755, 'yvm.sh'
    prefix.install Dir['*']
  end

  def caveats
    emptor = <<~EOS
      To load yvm in the shell add to your ~/.bashrc or ~/.zsh
      export YVM_DIR='#{prefix}'
      [ -r $YVM_DIR/yvm.sh ] && source $YVM_DIR/yvm.sh

      And for you fishers to your ~/.config/fish/config.fish
      set -x YVM_DIR '#{prefix}'
      source . $YVM_DIR/yvm.fish
    EOS
    emptor
  end

  test do
    system 'bash -l -c "yvm --version"'
  end
end
