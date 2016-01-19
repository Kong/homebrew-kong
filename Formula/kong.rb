class Kong < Formula
  homepage "https://getkong.org"
  desc "Open-source Microservice and API Gateway"
  revision 1

  stable do
    url "https://github.com/Mashape/kong/archive/0.5.4.tar.gz"
    sha256 "bdfa5fb49c07f83aabd2a8d7e308226f6f0363865f28c30504c70ba73b574f90"
  end

  head do
    url "https://github.com/mashape/kong.git", :branch => "next"
  end

  devel do
    url "https://github.com/mashape/kong.git", :tag => "0.6.0rc3"
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

  def caveats
    msg = ""
    if devel?
      msg += <<-EOS.undent
        Kong 0.6.0 requires Serf. You can use:

        brew cask install serf.

        if you want to use Homebrew to install it.
      EOS
    end
    msg
  end
end

