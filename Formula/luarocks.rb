class Luarocks < Formula
  homepage "https://luarocks.org"
  url "https://luarocks.org/releases/luarocks-3.0.4.tar.gz"
  sha256 "1236a307ca5c556c4fed9fdbd35a7e0e80ccf063024becc8c3bf212f37ff0edf"
  head "https://github.com/keplerproject/luarocks.git"

  patch :DATA

  depends_on "kong/kong/openresty"

  def install
    openresty = Formula["kong/kong/openresty"]

    # Install to the Cellar, but the tree to install modules is in HOMEBREW_PREFIX/opt/kong
    args = [
      "--prefix=#{prefix}",
      "--rocks-tree=#{HOMEBREW_PREFIX}/opt/kong",
      "--sysconfdir=#{prefix}/etc",
      "--with-lua=#{openresty.prefix}/luajit",
      "--with-lua-include=#{openresty.prefix}/luajit/include/luajit-2.1",
      "--lua-suffix=jit"
    ]

    ENV.deparallelize
    system "./configure", *args
    system "make build"
    system "make install"
  end

  def caveats; <<~EOS
    Rocks will be installed to: #{HOMEBREW_PREFIX}/opt/kong
    EOS
  end
end
# Do not attempt to create the rocks tree prefix directory,
# since /usr/local/opt/kong lies outside of our sandbox.
__END__
diff -u a/luarocks-2.4.2/Makefile b/luarocks-2.4.2/Makefile
--- luarocks-2.4.2/Makefile	2016-11-30 04:49:34.000000000 -0800
+++ luarocks-2.4.2-new/Makefile	2017-08-03 14:54:45.000000000 -0700
@@ -133,7 +133,6 @@
 	cp src/luarocks/site_config.lua "$(DESTDIR)$(LUADIR)/luarocks"
 
 write_sysconfig:
-	mkdir -p "$(DESTDIR)$(ROCKS_TREE)"
 	if [ ! -f "$(DESTDIR)$(CONFIG_FILE)" ] ;\
 	then \
 	   mkdir -p `dirname "$(DESTDIR)$(CONFIG_FILE)"` ;\
