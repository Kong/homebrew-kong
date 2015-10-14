class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.5.1.tar.gz"
    sha256 "9e321bc60786fb4b2cd9e82dfd08ac050e0661d69d3d6a24f73e8a0987f05dad"
  end

  head do
    url "https://github.com/mashape/kong.git"
  end

  depends_on "openssl"
  depends_on "dnsmasq"
  depends_on "mashape/kong/ngx_openresty"
  depends_on "mashape/kong/luarocks_luajit"

  option "with-cassandra", "Also install the cassandra formula from homebrew/cassandra"
  depends_on "cassandra" => :optional

  def install
    system "make install"
  end
end
