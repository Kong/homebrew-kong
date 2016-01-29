class Kong < Formula
  homepage "https://getkong.org"
  desc "Open-source Microservice and API Gateway"
  revision 1

  stable do
    url "https://github.com/Mashape/kong/archive/0.6.0.tar.gz"
    sha256 "b0320d1c519125713926963e59fbb3cf8969ecbb0d5fa5bfbd87c179c22290d2"
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
