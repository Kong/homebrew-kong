# From https://github.com/naartjie/homebrew-luajit
# Lighten (only luajit support) and allowing us to
# always use the version recommended for Kong.

require "formula"

class LuarocksLuajit < Formula
  homepage "http://luarocks.org"
  url "http://luarocks.org/releases/luarocks-2.2.2.tar.gz"
  sha256 "4f0427706873f30d898aeb1dfb6001b8a3478e46a5249d015c061fe675a1f022"
  head "https://github.com/keplerproject/luarocks.git"

  depends_on "luajit"

  fails_with :llvm do
    cause "Lua itself compiles with llvm, but may fail when other software tries to link."
  end

  def install
    # Install to the Cellar, but direct modules to HOMEBREW_PREFIX
    args = ["--prefix=#{prefix}",
            "--rocks-tree=#{HOMEBREW_PREFIX}",
            "--sysconfdir=#{etc}/luarocks"]

    luajit_prefix = Formula["luajit"].opt_prefix

    args << "--with-lua=#{luajit_prefix}"
    args << "--lua-version=5.1"
    args << "--lua-suffix=jit"
    args << "--with-lua-include=#{luajit_prefix}/include/luajit-2.0"

    system "./configure", *args
    system "make", "build"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    Rocks install to: #{HOMEBREW_PREFIX}/lib/luarocks/rocks

    You may need to run `luarocks install` inside the Homebrew build
    environment for rocks to successfully build. To do this, first run `brew sh`.
    EOS
  end

  test do
    system "#{bin}/luarocks", "install", "say"
  end
end
