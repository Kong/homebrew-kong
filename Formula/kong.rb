class Kong < Formula
  homepage "https://getkong.org"
  desc "Open source Microservices and API Gateway"

  stable do
    url "https://bintray.com/kong/kong-community-edition-src/download_file?file_path=kong-community-edition-0.11.0.tar.gz"
    sha256 "50305f52075d96b5b7ab3a051611bf7f28d263d7d45e2004572d9d3ef0ef8141"
  end

  #devel do
  #  url "https://github.com/Mashape/kong.git", :tag => "0.11.0rc2"
  #end

  head do
    url "https://github.com/Mashape/kong.git", :branch => "next"
  end

  patch :DATA

  depends_on "openssl"
  depends_on "mashape/kong/openresty"
  depends_on "mashape/kong/luarocks"

  def install
    system "luarocks-5.1 --tree=#{prefix} make OPENSSL_DIR=#{Formula['openssl'].opt_prefix}"
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
