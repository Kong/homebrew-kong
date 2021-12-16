class OpenrestyAT11583 < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  KONG_BUILD_TOOLS_VERSION = "4.8.1".freeze
  KONG_BUILD_TOOLS_SHA_SUM = "b5ab357f4ad2363627c0c1c70e0f759ad3492e6f11bf633844e063a3358c350c".freeze
  OPENRESTY_VERSION = "1.15.8.3".freeze
  OPENSSL_VERSION = "1.1.1g".freeze
  LUAROCKS_VERSION = "3.3.1".freeze
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
  end

  test do
    system "#{prefix}/openresty/bin/openresty", "-V"
    system "#{prefix}/openresty/bin/resty", "-V"
  end
end
