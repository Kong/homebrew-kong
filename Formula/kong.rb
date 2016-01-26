class Kong < Formula
  homepage "https://getkong.org"
  desc "Open-source Microservice and API Gateway"

  stable do
    url "https://github.com/Mashape/kong/archive/0.6.0.tar.gz"
    sha256 "7c604bafd0f3600ff2b7225ba69d60d3504fabb1c332a6b371b47d14019d973e"
  end

  head do
    url "https://github.com/mashape/kong.git", :branch => "next"
  end

  devel do
    url "https://github.com/mashape/kong.git", :branch => "next"
  end

  depends_on "openssl"
  depends_on "dnsmasq"
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
