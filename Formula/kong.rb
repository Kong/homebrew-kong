class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.5.0.tar.gz"
    sha256 "cd76bb8a52d535a899500ababcddd9933a028fb4e73b45b783923ccbf224ac67"
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
