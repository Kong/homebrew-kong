class Kong < Formula
  homepage "https://getkong.org"
  desc "Open-source Microservice and API Gateway"

  stable do
    url "https://github.com/Mashape/kong/archive/0.6.1.tar.gz"
    sha256 "da5ff5b1aa921574031f4defad6133dd229f523bc79479ffa8f4d8a92cfc3750"
  end

  head "https://github.com/mashape/kong.git", :branch => "next"

  depends_on "openssl"
  depends_on "dnsmasq"
  depends_on "ossp-uuid"
  depends_on "mashape/kong/luarocks"
  depends_on "mashape/kong/ngx_openresty"

  conflicts_with "cassandra",
        :because => "Kong only supports Cassandra 2.1/2.2"

  def install
    system "make", "install"
    # hack: to avoid the empty installation error, we override the kong script installed by
    # luarocks in 'make install' with a proper symlink from this Formula.
    rm "#{HOMEBREW_PREFIX}/bin/kong"
    bin.install "bin/kong"
  end

  def caveats; <<-EOS.undent
      Kong requires Serf. You can use:

      brew cask install serf.

      if you want to use Homebrew to install it.
    EOS
  end
end
