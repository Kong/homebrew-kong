class Kong < Formula
  homepage "http://getkong.org"

  stable do
    url "https://github.com/Mashape/kong/archive/0.5.2.tar.gz"
    sha256 "4f408d153df37241913d4da74914169fc883d3d41c7cf8fc5113b6df43dd4538"
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
