class Luarocks < Formula
  desc "Package manager for the Lua programming language"
  homepage "https://luarocks.org"
  url "https://luarocks.org/releases/luarocks-3.0.4.tar.gz"
  sha256 "1236a307ca5c556c4fed9fdbd35a7e0e80ccf063024becc8c3bf212f37ff0edf"
  head "https://github.com/luarocks/luarocks.git"

  depends_on "kong/kong/openresty"

  patch :DATA

  def install
    openresty_prefix = Formula["kong/kong/openresty"].prefix

    # Install to the Cellar, but the tree to install modules is in HOMEBREW_PREFIX/opt/kong
    args = [
      "--prefix=#{prefix}",
      "--rocks-tree=#{HOMEBREW_PREFIX}/opt/kong",
      "--sysconfdir=#{prefix}/etc",
      "--with-lua=#{openresty_prefix}/luajit",
      "--with-lua-include=#{openresty_prefix}/luajit/include/luajit-2.1",
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
diff -u a/luarocks-3.0.4/GNUmakefile b/luarocks-3.0.4/GNUmakefile
--- luarocks-3.0.4/GNUmakefile	2018-10-30 19:31:39.000000000 +0200
+++ luarocks-3.0.4-new/GNUmakefile	2018-12-19 02:20:03.000000000 +0200
@@ -146,7 +146,6 @@
 # ----------------------------------------

 bootstrap: luarocks $(DESTDIR)$(luarocksconfdir)/config-$(LUA_VERSION).lua
-	./luarocks make --tree="$(DESTDIR)$(rocks_tree)"

 # ----------------------------------------
 # Windows binary build
