class Luarocks < Formula
  homepage "https://luarocks.org"
  url "https://luarocks.org/releases/luarocks-2.4.2.tar.gz"
  sha256 "0e1ec34583e1b265e0fbafb64c8bd348705ad403fe85967fd05d3a659f74d2e5"
  head "https://github.com/keplerproject/luarocks.git"

  depends_on "mashape/kong/openresty"

  fails_with :llvm do
    cause "Lua itself compiles with llvm, but may fail when other software tries to link."
  end

  def install
    openresty = Formula["mashape/kong/openresty"]

    # Install to the Cellar, but the tree to install modules is in HOMEBREW_PREFIX
    args = [
      "--prefix=#{prefix}",
      "--rocks-tree=#{openresty.prefix}/luajit",
      "--sysconfdir=#{prefix}/etc",
      "--with-lua=#{openresty.prefix}/luajit",
      "--with-lua-include=#{openresty.prefix}/luajit/include/luajit-2.1",
      "--lua-suffix=jit"
    ]

    system "./configure", *args
    system "make build"
    system "make install"
  end

  def caveats; <<-EOS.undent
    Rocks will be installed to: <OPENRESTY_PREFIX>/luajit
    EOS
  end

  test do
    system "#{bin}/luarocks", "install", "say"
  end
end
