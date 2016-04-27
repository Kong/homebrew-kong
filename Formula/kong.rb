class Kong < Formula
  homepage "https://getkong.org"
  desc "Open-source Microservice and API Gateway"

  stable do
    url "https://github.com/Mashape/kong.git", :tag => "0.8.1"
  end

  #devel do
  #  url "https://github.com/mashape/kong.git", :tag => "0.8.0rc2"
  #end

  head do
    url "https://github.com/Mashape/kong.git", :branch => "next"
  end

  depends_on "openssl"
  depends_on "dnsmasq"
  depends_on "ossp-uuid"
  depends_on "serf"
  depends_on "mashape/kong/luarocks"
  depends_on "mashape/kong/ngx_openresty"

  conflicts_with "cassandra", :because => "Kong only supports Cassandra 2.1/2.2"

  def install
    system "make", "install"
    # To avoid the empty installation error, we override the kong script installed by
    # luarocks in 'make install' with a proper symlink from this Formula.
    rm "#{HOMEBREW_PREFIX}/bin/kong"
    bin.install "bin/kong"
  end
end
