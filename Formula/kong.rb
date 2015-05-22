class Kong < Formula
  homepage "http://getkong.org"
  url "https://github.com/Mashape/kong/archive/0.2.1.tar.gz"
  sha256 "a837fa22023d3b9edd8109e6ce75ea3702c655598bad2505f7de666bf4b9ca4e"
  head "https://github.com/mashape/kong.git"

  depends_on "openssl"
  depends_on "mashape/kong/ngx_openresty"
  depends_on "mashape/kong/luarocks_luajit"

  option "with-cassandra", "Also install the cassandra formula from homebrew/cassandra"
  depends_on "cassandra" => :optional

  def install
    # Download the ssl-cert-by-lua branch and add ssl.lua to the lua path
    system "curl -s -L -o #{buildpath}/ssl-cert-by-lua.tar.gz https://github.com/openresty/lua-nginx-module/archive/ssl-cert-by-lua.tar.gz"
    system "tar -xzf #{buildpath}/ssl-cert-by-lua.tar.gz"
    system %{
      echo '
        package = "ngxssl"
        version = "0.1-1"
        source = {
          url = "git://github.com/openresty/lua-nginx-module",
          branch = "ssl-cert-by-lua"
        }
        dependencies = {
          "lua >= 5.1"
        }
        build = {
          type = "builtin",
          modules = {
            ["ngx.ssl"] = "#{buildpath}/lua-nginx-module-ssl-cert-by-lua/lua/ngx/ssl.lua"
          }
        }
        ' > #{buildpath}/ngxssl-0.1-1.rockspec
    }
    system "luarocks make #{buildpath}/ngxssl-0.1-1.rockspec"
    system "make install"
  end
end
