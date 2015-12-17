# Forked from the Homebrew luajit Formula but considering LuaJIT 2.1
# as the stable release. The reason being that OpenResty uses 2.1, and
# by using the Homebrew luajit, we need it to be --devel, and there is
# no way to retrieve the prefix paths of a devel installed Formula for
# the Luarocks/OpenResty --with-lua-* arguments.

class Luajit < Formula
  homepage "http://luajit.org/luajit.html"
  desc "Just-In-Time Compiler (JIT) for the Lua programming language"
  url "http://luajit.org/git/luajit-2.0.git", :branch => "v2.1"
  version "2.1"
  revision 1

  option "with-debug", "Build with debugging symbols"
  option "with-52compat", "Build with additional Lua 5.2 compatibility"

  def install
    # 1 - Override the hardcoded gcc.
    # 2 - Remove the "-march=i686" so we can set the march in cflags.
    # Both changes should persist and were discussed upstream.
    inreplace "src/Makefile" do |f|
      f.change_make_var! "CC", ENV.cc
      f.change_make_var! "CCOPT_x86", ""
    end

    ENV.O2 # Respect the developer's choice.

    args = %W[PREFIX=#{prefix}]

    # This doesn't yet work under superenv because it removes "-g"
    args << "CCDEBUG=-g" if build.with? "debug"
    args << "INSTALL_TNAME=luajit"
    args << "XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT" if build.with? "52compat"

    system "make", "amalg", *args
    system "make", "install", *args

    # LuaJIT doesn't automatically symlink unversioned libraries:
    # https://github.com/Homebrew/homebrew/issues/45854.
    lib.install_symlink lib/"libluajit-5.1.2.0.4.dylib" => "libluajit.dylib"
    lib.install_symlink lib/"libluajit-5.1.a" => "libluajit.a"

    bin.install_symlink bin/"luajit" => "lua"

    # Having an empty Lua dir in Lib/share can screw with other Homebrew Luas.
    rm_rf lib/"lua"
    rm_rf share/"lua"
  end

  test do
    system "#{bin}/luajit", "-e", <<-EOS.undent
      local ffi = require("ffi")
      ffi.cdef("int printf(const char *fmt, ...);")
      ffi.C.printf("Hello %s!\\n", "#{ENV["USER"]}")
    EOS
  end
end
