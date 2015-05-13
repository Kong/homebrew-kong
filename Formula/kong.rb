class Kong < Formula
  homepage "http://getkong.org"
  url "https://github.com/Mashape/kong/archive/0.2.1.tar.gz"
  sha256 "a837fa22023d3b9edd8109e6ce75ea3702c655598bad2505f7de666bf4b9ca4e"
  head "https://github.com/mashape/kong.git"

  depends_on 'openssl'
  depends_on 'mashape/kong/ngx_openresty'
  depends_on 'mashape/kong/luarocks_luajit'

  option "with-cassandra", "Also install the cassandra formula from homebrew/cassandra"
  depends_on 'cassandra' => :optional

  def install
    system "make install"
  end
end
