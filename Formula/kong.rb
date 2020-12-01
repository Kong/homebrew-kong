class Kong < Formula
  desc "Open source Microservices and API Gateway"
  homepage "https://docs.konghq.com"

  KONG_OPENRESTY_VERSION = "1.17.8.2"

  stable do
    url "https://bintray.com/kong/kong-src/download_file?file_path=kong-2.2.1.tar.gz"
    sha256 "2d3714a2c91ed9c6f578c2dfe9da0d86bcc07e5f942830085a4be167658bcc5d"
  end

  #devel do
  #  url "https://github.com/Kong/kong.git", :tag => "2.1.0-rc.1"
  #end

  head do
    url "https://github.com/Kong/kong.git", :branch => "next"
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
