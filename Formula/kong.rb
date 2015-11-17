class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.5.3.tar.gz"
    sha256 "2e9579c88290dc40519dd760d5b25c7adb5bf499b03c670be038c03864b54998"
  end

  head do
    url "https://github.com/mashape/kong.git", :branch => "next"
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
