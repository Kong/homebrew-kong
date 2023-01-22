class OpenrestyAT12141 < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  KONG_BUILD_TOOLS_VERSION = "4.42.0".freeze
  KONG_BUILD_TOOLS_SHA_SUM = "3121a7b4d3f36f9c6713c7a0de8bf4e74c4c6562b6e4ce3e4515075dd47d8285".freeze
  OPENRESTY_VERSION = "1.21.4.1".freeze
  OPENSSL_VERSION = "1.1.1q".freeze
  LUAROCKS_VERSION = "3.9.1".freeze
  PCRE_VERSION = "8.45".freeze
  ATC_ROUTER_VERSION = "1.0.1".freeze
  RESTY_EVENTS_VERSION = "0.1.3".freeze
  RESTY_LMDB_VERSION = "1.0.0".freeze
  RESTY_WEBSOCKET_VERSION = "0.3.0".freeze

  url "https://github.com/Kong/kong-build-tools/archive/#{KONG_BUILD_TOOLS_VERSION}.tar.gz"
  version OPENRESTY_VERSION
  sha256 KONG_BUILD_TOOLS_SHA_SUM

  keg_only :versioned_formula

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "rust" => :build
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
      "--ssl-provider openssl",
      "--atc-router #{ATC_ROUTER_VERSION}",
      "--resty-events #{RESTY_EVENTS_VERSION}",
      "--resty-lmdb #{RESTY_LMDB_VERSION}",
      "--resty-websocket #{RESTY_WEBSOCKET_VERSION}",
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
    system "#{prefix}/openresty/bin/resty", "-e", "require(\"ffi\").load(\"jq\")"
  end
end
