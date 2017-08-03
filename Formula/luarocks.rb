class Luarocks < Formula
  homepage "https://luarocks.org"
  url "https://luarocks.org/releases/luarocks-2.4.2.tar.gz"
  sha256 "0e1ec34583e1b265e0fbafb64c8bd348705ad403fe85967fd05d3a659f74d2e5"
  head "https://github.com/keplerproject/luarocks.git"

  depends_on "mashape/kong/openresty"

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
    system "#{bin}/luarocks install luarocks"
  end

  def caveats; <<-EOS.undent
    Rocks will be installed to: <OPENRESTY_PREFIX>/luajit
    EOS
  end
end
