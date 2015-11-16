class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.5.3.tar.gz"
    sha256 "abbfe0a3f3d45026672483890a3ffe79279d5cd64a5241edccc01b6c41862cff"
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
