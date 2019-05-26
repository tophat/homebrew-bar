# Yarn Version Manager
class Yvm < Formula
  desc "Manage multiple versions of Yarn"
  homepage "https://yvm.js.org"
  # Should only be updated if a newer version is listed as a stable release
  url "https://github.com/tophat/yvm/releases/download/v3.4.0/yvm.js"
  sha256 "5fa5f4ae76063dde9ce6be016c610d610d2b72d59e6af4573dcc99c2e3bd9495"

  bottle :unneeded

  depends_on "node" => [:recommended] # Can be ignored if node is already managed

  conflicts_with "hadoop", :because => "both install `yarn` binaries"
  conflicts_with "yarn", :because => "yvm installs and manages yarn"

  def install
    File.write("#{ENV["HOME"]}/.bashrc", "")
    mkdir_p "#{ENV["HOME"]}/.config/fish"
    File.write("#{ENV["HOME"]}/.config/fish/config.fish", "")
    ENV["YVM_INSTALL_DIR"] = "."
    system "node", "yvm.js", "configure-shell"
    update_self_disabled = "echo 'YVM update-self disabled. Use `brew upgrade yvm`.'"
    inreplace "yvm.sh" do |s|
      s.gsub! 'YVM_DIR=${YVM_DIR-"${HOME}/.yvm"}', "YVM_DIR='#{prefix}'"
      s.gsub! "curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js | YVM_INSTALL_DIR=${YVM_DIR} node", update_self_disabled
    end
    inreplace "yvm.fish" do |s|
      s.gsub! 'set -q YVM_DIR; or set -gx YVM_DIR "$HOME/.yvm"', "set -gx YVM_DIR '#{prefix}'"
      s.gsub! "env YVM_INSTALL_DIR=$YVM_DIR curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js | node", update_self_disabled
    end
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
    system "node", "#{prefix}/yvm.js", "configure-shell"
    system "bash -i -c 'echo $YVM_DIR'"
    system "bash -i -c 'yvm ls-remote'"
    ENV["YVM_DIR"] = prefix.to_s
    system "#{prefix}/shim/yarn", "--version"
    system "bash -i -c 'yvm ls'"
  end
end
