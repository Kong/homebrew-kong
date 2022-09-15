class Kong < Formula
  desc "Open source Microservices and API Gateway"
  homepage "https://docs.konghq.com"

  KONG_OPENRESTY_VERSION = "1.21.4.1".freeze
  KONG_VERSION = "3.0.0".freeze

  stable do
    url "https://download.konghq.com/gateway-src/kong-#{KONG_VERSION}.tar.gz"
    sha256 "73a8c39b5286d7f43d90fef704c30a926e44864a7dcb09802bf5c43709987117"
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

    prefix.install "kong/include"

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

__END__
diff --git a/bin/kong b/bin/kong
--- a/bin/kong
+++ b/bin/kong
@@ -4,6 +4,7 @@ setmetatable(_G, nil)
#
# patch bin/kong's LUA_PATH & LUA_CPATH with HOMEBREW_PREFIX (both intel & arm)
# homebrew substitutes "HOMEBREW_PREFIX" when patching:
#   https://docs.brew.sh/Formula-Cookbook#patches
#
 
 pcall(require, "luarocks.loader")
 
-package.path = (os.getenv("KONG_LUA_PATH_OVERRIDE") or "") .. "./?.lua;./?/init.lua;" .. package.path
+package.cpath = (os.getenv("KONG_LUA_CPATH_OVERRIDE") or "") .. "HOMEBREW_PREFIX/lib/lua/5.1/?.so;" .. package.cpath
+package.path = (os.getenv("KONG_LUA_PATH_OVERRIDE") or "") .. "./?.lua;./?/init.lua;" .. "HOMEBREW_PREFIX/share/lua/5.1/?.lua;HOMEBREW_PREFIX/share/lua/5.1/?/init.lua;" .. package.path
 
 require("kong.cmd.init")(arg)
diff --git a/kong/templates/kong_defaults.lua b/kong/templates/kong_defaults.lua
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
+lua_package_path = ./?.lua;./?/init.lua;HOMEBREW_PREFIX/share/lua/5.1/?.lua;HOMEBREW_PREFIX/share/lua/5.1/?/init.lua;;
+lua_package_cpath = HOMEBREW_PREFIX/lib/lua/5.1/?.so;;
 
 role = traditional
 kic = off
diff -r -u a/kong/cmd/prepare.lua b/kong/cmd/prepare.lua
--- a/kong/cmd/prepare.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/cmd/prepare.lua	2022-09-15 10:53:58.000000000 +0200
@@ -23,8 +23,8 @@

 Example usage:
  kong migrations up
- kong prepare -p /usr/local/kong -c kong.conf
- nginx -p /usr/local/kong -c /usr/local/kong/nginx.conf
+ kong prepare -p HOMEBREW_PREFIX -c kong.conf
+ nginx -p HOMEBREW_PREFIX -c HOMEBREW_PREFIX/nginx.conf

 Options:
  -c,--conf       (optional string) configuration file
diff -r -u a/kong/pdk/init.lua b/kong/pdk/init.lua
--- a/kong/pdk/init.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/pdk/init.lua	2022-09-15 10:54:21.000000000 +0200
@@ -49,7 +49,7 @@
 --
 -- @field kong.configuration
 -- @usage
--- print(kong.configuration.prefix) -- "/usr/local/kong"
+-- print(kong.configuration.prefix) -- "HOMEBREW_PREFIX"
 -- -- this table is read-only; the following throws an error:
 -- kong.configuration.prefix = "foo"

diff -r -u a/kong/runloop/plugin_servers/process.lua b/kong/runloop/plugin_servers/process.lua
--- a/kong/runloop/plugin_servers/process.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/runloop/plugin_servers/process.lua	2022-09-15 10:54:10.000000000 +0200
@@ -61,7 +61,7 @@
       local env_prefix = "pluginserver_" .. name:gsub("-", "_")
       _servers[i] = {
         name = name,
-        socket = config[env_prefix .. "_socket"] or "/usr/local/kong/" .. name .. ".socket",
+        socket = config[env_prefix .. "_socket"] or "HOMEBREW_PREFIX/" .. name .. ".socket",
         start_command = config[env_prefix .. "_start_cmd"] or ifexists("/usr/local/bin/"..name),
         query_command = config[env_prefix .. "_query_cmd"] or ifexists("/usr/local/bin/query_"..name),
       }
diff -r -u a/kong/tools/grpc.lua b/kong/tools/grpc.lua
--- a/kong/tools/grpc.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/tools/grpc.lua	2022-09-15 10:54:04.000000000 +0200
@@ -67,7 +67,7 @@
   local protoc_instance = protoc.new()
   -- order by priority
   for _, v in ipairs {
-    "/usr/local/kong/include",
+    "HOMEBREW_PREFIX/include",
     "/usr/local/opt/protobuf/include/", -- homebrew
     "/usr/include",
     "kong/include",
