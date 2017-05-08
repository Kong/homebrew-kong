class Kong < Formula
  homepage "https://getkong.org"
  desc "Open source Microservices and API Gateway"

  stable do
    url "https://github.com/Mashape/kong.git", :tag => "0.10.2"
  end

  #devel do
  #  url "https://github.com/mashape/kong.git", :tag => "0.10.0rc4"
  #end

  head do
    url "https://github.com/Mashape/kong.git", :branch => "next"
  end

  depends_on "openssl"
  depends_on "serf"
  depends_on "mashape/kong/openresty"
  depends_on "mashape/kong/luarocks"

  patch :DATA

  def install
    system "luarocks make OPENSSL_DIR=#{Formula['openssl'].opt_prefix} --local"
    bin.install "bin/kong"
  end
end

__END__
diff --git a/bin/busted b/bin/busted
index 991b418e..a6d9bb72 100755
--- a/bin/busted
+++ b/bin/busted
@@ -1,5 +1,7 @@
 #!/usr/bin/env resty
 
+require "luarocks.loader"
+
 require("kong.core.globalpatches")({
   cli = true,
   rbusted = true
diff --git a/bin/kong b/bin/kong
index 3311ce22..c144f46d 100755
--- a/bin/kong
+++ b/bin/kong
@@ -1,5 +1,7 @@
 #!/usr/bin/env resty
 
+require "luarocks.loader"
+
 package.path = "?/init.lua;"..package.path
 
 require("kong.cmd.init")(arg)
diff --git a/kong/templates/nginx_kong.lua b/kong/templates/nginx_kong.lua
index 536dad9a..66a59f85 100644
--- a/kong/templates/nginx_kong.lua
+++ b/kong/templates/nginx_kong.lua
@@ -45,6 +45,7 @@ lua_ssl_verify_depth ${{LUA_SSL_VERIFY_DEPTH}};
 > end
 
 init_by_lua_block {
+    require "luarocks.loader"
     require 'resty.core'
     kong = require 'kong'
     kong.init()

