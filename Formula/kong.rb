class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.4.2.tar.gz"
    sha256 "838d7672275e23a1bebd763890bd840277657c18a9ddf9ad1ac75a49bf56c4b2"
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
