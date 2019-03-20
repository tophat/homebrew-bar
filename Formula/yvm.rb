# Yarn Version Manager
class Yvm < Formula
  desc "Manage multiple versions of Yarn"
  homepage "https://yvm.js.org"
  # Should only be updated if a newer version is listed as a stable release
  url "https://github.com/tophat/yvm/releases/download/v2.4.1/yvm.zip"
  sha256 "82e0e3ee1e66ad389641fef9d9c3a164124cd63e89323a77e03a30fa9d5ecfdf"

  bottle :unneeded

  depends_on "node" => [:recommended, :optional] # Ignore if node already managed

  conflicts_with "hadoop", :because => "both install `yarn` binaries"
  conflicts_with "yarn", :because => "yvm installs and manages yarn"

  def install
    update_self_disabled = "echo 'YVM update-self disabled. Use `brew upgrade yvm`.'"
    inreplace "yvm.sh" do |s|
      s.gsub! 'YVM_DIR=${YVM_DIR-"${HOME}/.yvm"}', "YVM_DIR='#{prefix}'"
      s.gsub! "curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.sh | YVM_INSTALL_DIR=${YVM_DIR} bash", update_self_disabled
    end
    inreplace "yvm.fish" do |s|
      s.gsub! 'set -q YVM_DIR; or set -U YVM_DIR "$HOME/.yvm"', "set -U YVM_DIR '#{prefix}'"
      s.gsub! "env YVM_INSTALL_DIR=$YVM_DIR curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.sh | bash", update_self_disabled
    end
    chmod 0755, "yvm.sh"
    makedirs "/usr/local/var/yvm/versions"
    ln_s "/usr/local/var/yvm/versions", "./versions"
    File.write(".version", "{ \"version\": \"#{version}\" }")
    prefix.install [".version", "versions", "node_modules", "yvm.sh", "yvm.fish", "yvm.js", "yvm-exec.js"]
  end

  def caveats
    emptor = <<~EOS
      To load yvm in the shell add to your ~/.bashrc or ~/.zsh
      export YVM_DIR="#{prefix}"
      [ -r $YVM_DIR/yvm.sh ] && source $YVM_DIR/yvm.sh

      And for fishers, add to your ~/.config/fish/config.fish
      set -x YVM_DIR "#{prefix}"
      source . $YVM_DIR/yvm.fish

      If you have previously installed YVM, link the versions folder
      to allow all brewed YVM access to the managed yarn distributions
      $ ln -sF ~/.yvm/versions /usr/local/var/yvm
    EOS
    emptor
  end

  test do
    system "#{prefix}/yvm.sh ls"
    system "#{prefix}/yvm.sh ls-remote"
  end
end
