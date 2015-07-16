class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.4.0.tar.gz"
    sha256 "2d2232c373dbe85e21be4e38319123a2de72cfd3eb6629aaa70a340cb13735c6"
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
