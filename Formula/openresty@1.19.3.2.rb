class OpenrestyAT11932 < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  KONG_BUILD_TOOLS_VERSION = "4.22.0".freeze
  KONG_BUILD_TOOLS_SHA_SUM = "5ded6277bcbbddcba96e52be842c128b3959ac3d0330b14b99b9a0ac02ae3687".freeze
  OPENRESTY_VERSION = "1.19.3.2".freeze
  OPENSSL_VERSION = "1.1.1k".freeze
  LUAROCKS_VERSION = "3.5.0".freeze
  PCRE_VERSION = "8.44".freeze

  url "https://github.com/Kong/kong-build-tools/archive/#{KONG_BUILD_TOOLS_VERSION}.tar.gz"
  version OPENRESTY_VERSION
  sha256 KONG_BUILD_TOOLS_SHA_SUM

  keg_only :versioned_formula

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "coreutils"

  def install
    # LuaJIT build is crashing in macOS Catalina. The defaults
    # for stack checks changed (they are on by default when the
    # target is 10.15). An existing issue in Clang will generate
    # code that crashes under some circumstances if stack checks
    # are enabled.
    # https://forums.developer.apple.com/thread/121887
    ENV.append_to_cflags "-fno-stack-check" if DevelopmentTools.clang_build_version >= 1010

    args = [
      "--prefix #{prefix}",
      "--openresty #{OPENRESTY_VERSION}",
      "--openssl #{OPENSSL_VERSION}",
      "--luarocks #{LUAROCKS_VERSION}",
      "--pcre #{PCRE_VERSION}",
      "-j #{ENV.make_jobs}",
    ]

    # Debugging mode, unfortunately without debugging symbols
    if build.with? "debug"
      args << "--debug"

      opoo "OpenResty and dependencies will be built --with-debug option," \
           "but without debugging symbols. For debugging symbols you have to" \
           "compile it by hand."
    end

    Dir.chdir("openresty-build-tools")
    system "./kong-ngx-build", *args

    bin.install_symlink "#{prefix}/openresty/nginx/sbin/nginx"
    bin.install_symlink "#{prefix}/openresty/bin/openresty"
    bin.install_symlink "#{prefix}/openresty/bin/resty"
    bin.install_symlink "#{prefix}/luarocks/bin/luarocks"
  end

  test do
    system "#{bin}/openresty", "-V"
  end
end
