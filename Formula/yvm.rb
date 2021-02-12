# Yarn Version Manager
class Yvm < Formula
  desc "Manage multiple versions of Yarn"
  homepage "https://yvm.js.org"
  # Should only be updated if a newer version is listed as a stable release
  url "https://github.com/tophat/yvm/releases/download/v4.1.3/yvm.js"
  sha256 "e2a4e7d0191aa55dfd4d3749549aa2ccd138ef71beaa54b96a262dee929ba01f"

  bottle :unneeded

  depends_on "node" => [:recommended] # Can be ignored if node is already managed

  conflicts_with "hadoop", because: "both install `yarn` binaries"
  conflicts_with "yarn", because: "yvm installs and manages yarn"

  def install
    File.write("#{ENV["HOME"]}/.bashrc", "")
    mkdir_p "#{ENV["HOME"]}/.config/fish"
    File.write("#{ENV["HOME"]}/.config/fish/config.fish", "")
    system "node", "yvm.js", "configure-shell", "--yvmDir", "."
    update_self_disabled = "echo 'YVM update-self disabled. Use `brew upgrade yvm`.'"
    inreplace "yvm.sh" do |s|
      s.gsub! 'YVM_DIR=${YVM_DIR-"${HOME}/.yvm"}', "YVM_DIR='#{prefix}'"
      s.gsub! "curl -fsSL https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js"\
              " | YVM_INSTALL_DIR=${YVM_DIR} node", update_self_disabled
    end
    inreplace "yvm.fish" do |s|
      s.gsub! 'set -q YVM_DIR; or set -gx YVM_DIR "$HOME/.yvm"', "set -gx YVM_DIR '#{prefix}'"
      s.gsub! "env YVM_INSTALL_DIR=$YVM_DIR curl -fsSL https://raw.githubusercontent.com/tophat/yvm"\
              "/master/scripts/install.js | node", update_self_disabled
    end
    yarn_versions_dir = "#{ENV["HOME"]}/.yvm/versions"
    mkdir_p yarn_versions_dir
    ln_sf yarn_versions_dir, "./versions"
    File.write(".version", "{ \"version\": \"#{version}\" }")
    prefix.install [".version", "versions", "shim", "yvm.sh", "yvm.fish", "yvm.js"]
  end

  def caveats
    <<~EOS
      Run the following command to configure your shell rc file
      $ node "#{prefix}/yvm.js" configure-shell --yvmDir "#{prefix}"
    EOS
  end

  test do
    File.write("#{ENV["HOME"]}/.bashrc", "")
    system "node", "#{prefix}/yvm.js", "configure-shell", "--yvmDir", prefix.to_s
    assert_match prefix.to_s, shell_output("bash -i -c 'echo $YVM_DIR'").strip
    shell_output("bash -i -c 'yvm ls-remote'")
    File.write("./.yvmrc", "1.22.5")
    assert_match "1.22.5", shell_output("bash -i -c '#{prefix}/shim/yarn --version'").strip
    shell_output("bash -i -c 'yvm ls'")
  end
end
