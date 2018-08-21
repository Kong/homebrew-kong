class Kong < Formula
  homepage "https://getkong.org"
  desc "Open source Microservices and API Gateway"

  stable do
    url "https://bintray.com/kong/kong-community-edition-src/download_file?file_path=dists%2Fkong-community-edition-0.14.1.tar.gz"
    sha256 "945a90568838ffb7ee89e6816576a26aae0e860b5ff0a4c396f4299062eb0001"
  end

  #devel do
  # url "https://github.com/Kong/kong.git", :tag => "0.13.0rc2"
  #end

  head do
    url "https://github.com/Kong/kong.git", :branch => "next"
  end

  patch :DATA

  depends_on "openssl"
  depends_on "kong/kong/openresty"
  depends_on "kong/kong/luarocks"

  def install
    system "luarocks-5.1 --tree=#{prefix} make CRYPTO_DIR=#{Formula['openssl'].opt_prefix} OPENSSL_DIR=#{Formula['openssl'].opt_prefix}"
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
