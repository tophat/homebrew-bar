# Yarn Version Manager
class Yvm < Formula
  desc "Manage multiple versions of Yarn"
  homepage "https://yvm.js.org"
  # Should only be updated if a newer version is listed as a stable release
  url "https://github.com/tophat/yvm/releases/download/v3.2.2/yvm.zip"
  sha256 "ae3db7c910f44481704a6b7f9bfba2ddd110417a3e27034a509150e38d051b2a"

  bottle :unneeded

  depends_on "node" => [:recommended] # Can be ignored if node already managed

  conflicts_with "hadoop", :because => "both install `yarn` binaries"
  conflicts_with "yarn", :because => "yvm installs and manages yarn"

  def install
    update_self_disabled = "echo 'YVM update-self disabled. Use `brew upgrade yvm`.'"
    inreplace "yvm.sh" do |s|
      s.gsub! 'YVM_DIR=${YVM_DIR-"${HOME}/.yvm"}', "YVM_DIR='#{prefix}'"
      s.gsub! "curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js | YVM_INSTALL_DIR=${YVM_DIR} node", update_self_disabled
    end
    inreplace "yvm.fish" do |s|
      s.gsub! 'set -q YVM_DIR; or set -U YVM_DIR "$HOME/.yvm"', "set -U YVM_DIR '#{prefix}'"
      s.gsub! "env YVM_INSTALL_DIR=$YVM_DIR curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js | node", update_self_disabled
    end
    chmod 0755, "yvm.sh"
    chmod 0755, "shim/yarn"
    mkdir_p "/usr/local/var/yvm/versions"
    ln_s "/usr/local/var/yvm/versions", "./versions"
    File.write(".version", "{ \"version\": \"#{version}\" }")
    prefix.install [".version", "versions", "node_modules", "shim", "yvm.sh", "yvm.fish", "yvm.js"]
  end

  def caveats
    emptor = <<~EOS
      Run the following command to configure your shell rc file
      $ YVM_INSTALL_DIR="#{prefix}" node "#{prefix}/yvm.js" configure-shell

      If you have previously installed YVM, link the versions folder
      to allow all brewed YVM access to the managed yarn distributions
      $ ln -sF ~/.yvm/versions /usr/local/var/yvm
    EOS
    emptor
  end

  test do
    system "#{prefix}/yvm.sh", "ls"
    system "#{prefix}/yvm.sh", "ls-remote"
    system "#{prefix}/yvm.sh", "configure-shell"
    system "#{prefix}/shim/yarn", "--version"
  end
end
