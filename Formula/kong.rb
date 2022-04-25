class Kong < Formula
  desc "Open source Microservices and API Gateway"
  homepage "https://docs.konghq.com"

  KONG_OPENRESTY_VERSION = "1.19.3.2".freeze
  KONG_VERSION = "2.5.2".freeze

  stable do
    url "https://download.konghq.com/gateway-src/kong-#{KONG_VERSION}.tar.gz"
    sha256 "eb3bc8a577dbd097f211fa453af07aad74160f1fd06e16d27c0cbff0c93e4562"
  end

  head do
    url "https://github.com/Kong/kong.git", branch: "master"
  end

  depends_on "libyaml"
  depends_on "coreutils"
  depends_on "kong/kong/openresty@#{KONG_OPENRESTY_VERSION}"

  patch :DATA

  def install
    openresty_prefix = Formula["kong/kong/openresty@#{KONG_OPENRESTY_VERSION}"].prefix

    luarocks_prefix = openresty_prefix + "luarocks"
    openssl_prefix = openresty_prefix + "openssl"

    bin.install_symlink "#{openresty_prefix}/openresty/nginx/sbin/nginx"
    bin.install_symlink "#{openresty_prefix}/openresty/bin/openresty"
    bin.install_symlink "#{openresty_prefix}/openresty/bin/resty"
    bin.install_symlink "#{luarocks_prefix}/bin/luarocks"

    yaml_libdir = Formula["libyaml"].opt_lib
    yaml_incdir = Formula["libyaml"].opt_include

    system "#{luarocks_prefix}/bin/luarocks",
           "--tree=#{prefix}",
           "make",
           "CRYPTO_DIR=#{openssl_prefix}",
           "OPENSSL_DIR=#{openssl_prefix}",
           "YAML_LIBDIR=#{yaml_libdir}",
           "YAML_INCDIR=#{yaml_incdir}"

    bin.install "bin/kong"
  end

  test do
    tempfile = `gmktemp --dry-run`
    system "#{bin}/kong version -vv 2>&1 | grep 'Kong:'"
    system "kong", "config", "init", tempfile
    system "kong", "check", tempfile
  end
end

# patch Kong default `prefix` to `HOMEBREW_PREFIX/opt/kong`
# to ensure it's writeable
# additionally, add brew on m1 paths to lua_path and lua_cpath
__END__
diff --git a/bin/kong b/bin/kong
index 3e0ecf97d..b03e18a23 100755
--- a/bin/kong
+++ b/bin/kong
@@ -4,6 +4,7 @@ setmetatable(_G, nil)
 
 pcall(require, "luarocks.loader")
 
-package.path = (os.getenv("KONG_LUA_PATH_OVERRIDE") or "") .. "./?.lua;./?/init.lua;" .. package.path
+package.cpath = (os.getenv("KONG_LUA_CPATH_OVERRIDE") or "") .. "/opt/homebrew/lib/lua/5.1/?.so;" .. package.cpath
+package.path = (os.getenv("KONG_LUA_PATH_OVERRIDE") or "") .. "./?.lua;./?/init.lua;" .. "/opt/homebrew/share/lua/5.1/?.lua;/opt/homebrew/share/lua/5.1/?/init.lua;" .. package.path
 
 require("kong.cmd.init")(arg)
diff --git a/kong/templates/kong_defaults.lua b/kong/templates/kong_defaults.lua
index 5937dad10..c3387fded 100644
--- a/kong/templates/kong_defaults.lua
+++ b/kong/templates/kong_defaults.lua
@@ -1,5 +1,5 @@
 return [[
-prefix = /usr/local/kong/
+prefix = HOMEBREW_PREFIX/opt/kong/
 log_level = notice
 proxy_access_log = logs/access.log
 proxy_error_log = logs/error.log
@@ -166,8 +166,8 @@ lua_socket_pool_size = 30
 lua_ssl_trusted_certificate = NONE
 lua_ssl_verify_depth = 1
 lua_ssl_protocols = TLSv1.1 TLSv1.2 TLSv1.3
-lua_package_path = ./?.lua;./?/init.lua;
-lua_package_cpath = NONE
+lua_package_path = ./?.lua;./?/init.lua;/opt/homebrew/share/lua/5.1/?.lua;/opt/homebrew/share/lua/5.1/?/init.lua;;
+lua_package_cpath = /opt/homebrew/lib/lua/5.1/?.so;;
 
 role = traditional
 kic = off
