class Kong < Formula
  homepage "http://getkong.org"
  url "http://github.com/Mashape/kong/releases/download/0.1.1beta-2/kong-0.1.1beta.tar.gz"
  version "0.1.1beta"
  sha256 "6abfea43c705b58e3700b60e4e0bffd529a0bb89ecb311a532d788520f27c70c"

  depends_on 'openssl'
  depends_on 'mashape/kong/ngx_openresty'
  depends_on 'naartjie/luajit/luarocks-luajit'
  option "with-cassandra", "Also install the cassandra formula from homebrew/cassandra"
  depends_on 'cassandra' => :optional

  def install
    system "make install"
  end
end
