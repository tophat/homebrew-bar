# Yarn Version Manager
class Yvm < Formula
  desc "Manage multiple versions of Yarn"
  homepage "https://yvm.js.org"
  # Should only be updated if a newer version is listed as a stable release
  url "https://github.com/tophat/yvm/releases/download/v3.2.3/yvm.zip"
  sha256 "de393b193e4acbbb4c720e1a6c0eaf40693df9689caccb47414015251aa1f65b"

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
      s.gsub! 'set -q YVM_DIR; or set -gx YVM_DIR "$HOME/.yvm"', "set -gx YVM_DIR '#{prefix}'"
      s.gsub! "env YVM_INSTALL_DIR=$YVM_DIR curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js | node", update_self_disabled
    end
    chmod 0755, "yvm.sh"
    chmod 0755, "shim/yarn"
    mkdir_p "/usr/local/var/yvm/versions"
    ln_sf "/usr/local/var/yvm/versions", "./versions"
    File.write(".version", "{ \"version\": \"#{version}\" }")
    prefix.install [".version", "versions", "shim", "yvm.sh", "yvm.fish", "yvm.js"]
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
    File.write("#{ENV["HOME"]}/.bashrc", "")
    ENV["YVM_INSTALL_DIR"] = prefix.to_s
    system "#{prefix}/yvm.sh", "configure-shell"
    system "bash -i -c 'echo $YVM_DIR'"
    system "bash -i -c 'yvm ls-remote'"
    ENV["YVM_DIR"] = prefix.to_s
    system "#{prefix}/shim/yarn", "--version"
    system "bash -i -c 'yvm ls'"
  end
end
