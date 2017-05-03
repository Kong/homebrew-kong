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
    system "luarocks make OPENSSL_DIR=#{Formula['openssl'].opt_prefix}"
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
diff --git a/kong/kong.lua b/kong/kong.lua
index 952f8427..66530bf9 100644
--- a/kong/kong.lua
+++ b/kong/kong.lua
@@ -24,6 +24,8 @@
 -- |[[    ]]|
 -- ==========
 
+require "luarocks.loader"
+
 do
   -- let's ensure the required shared dictionaries are
   -- declared via lua_shared_dict in the Nginx conf

