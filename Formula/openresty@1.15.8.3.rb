class OpenrestyAT11583 < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  KONG_BUILD_TOOLS_VERSION = "4.8.1"
  KONG_BUILD_TOOLS_SHA_SUM = "022387f06f351599ea34342486254dfd57fc682169de236d9bb04fc1e4add610"
  OPENRESTY_VERSION = "1.15.8.3"
  OPENSSL_VERSION = "1.1.1g"
  LUAROCKS_VERSION = "3.3.1"
  PCRE_VERSION = "8.44"

  version OPENRESTY_VERSION

  url "https://github.com/Kong/kong-build-tools/archive/#{KONG_BUILD_TOOLS_VERSION}.zip"
  sha256 KONG_BUILD_TOOLS_SHA_SUM

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "coreutils"
  conflicts_with "kong/kong/luarocks", :because => "We switched over to a new build method and LuaRocks no longer needs to be installed separately. Please remove it with \"brew remove kong/kong/luarocks\"."

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
      "-j #{ENV.make_jobs}"
    ]

    # Debugging mode, unfortunately without debugging symbols
    if build.with? "debug"
      args << "--debug"

      opoo "OpenResty and dependencies will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    Dir.chdir('openresty-build-tools')
    system "./kong-ngx-build", *args

    bin.install_symlink "#{prefix}/openresty/nginx/sbin/nginx"
    bin.install_symlink "#{prefix}/openresty/bin/openresty"
    bin.install_symlink "#{prefix}/openresty/bin/resty"
    bin.install_symlink "#{prefix}/luarocks/bin/luarocks"
  end
end
