class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.3.1.tar.gz"
    sha256 "6316bf1943054edabfbd334aebbed44fc772a3ae04893cbbf22f2f75901ac3d8"
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
