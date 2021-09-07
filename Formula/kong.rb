class Kong < Formula
  desc "Open source Microservices and API Gateway"
  homepage "https://docs.konghq.com"

  KONG_OPENRESTY_VERSION = "1.19.3.2"
  KONG_VERSION = "2.5.1"

  stable do
    url "https://download.konghq.com/gateway-src/kong-#{KONG_VERSION}.tar.gz"
    sha256 "587a7f07410556daebedc25a3fbfafbf0e32da4a83fa09d7b028170989e8d191"
  end

  head do
    url "https://github.com/Kong/kong.git", :branch => "master"
  end

  depends_on "libyaml"
  depends_on "kong/kong/openresty@#{KONG_OPENRESTY_VERSION}"

  patch :DATA

  def install
    openresty_prefix = Formula["kong/kong/openresty@#{KONG_OPENRESTY_VERSION}"].prefix

    luarocks_prefix = openresty_prefix + "luarocks"
    openssl_prefix = openresty_prefix + "openssl"

    system "#{luarocks_prefix}/bin/luarocks",
           "--tree=#{prefix}",
           "make",
           "CRYPTO_DIR=#{openssl_prefix}",
           "OPENSSL_DIR=#{openssl_prefix}"

    bin.install "bin/kong"
  end
end

# patch Kong default `prefix` to `/usr/local/opt/kong` as `/usr/local/`
# not writable by non root user on OSX
__END__
diff --git a/kong/templates/kong_defaults.lua b/kong/templates/kong_defaults.lua
index e38b475..7a74a2f 100644
--- a/kong/templates/kong_defaults.lua
+++ b/kong/templates/kong_defaults.lua
@@ -1,5 +1,5 @@
 return [[
-prefix = /usr/local/kong/
+prefix = /usr/local/opt/kong/
 log_level = notice
 proxy_access_log = logs/access.log
 proxy_error_log = logs/error.log
