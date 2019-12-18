class OpenrestyAT11362 < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  version "1.13.6.2"

  stable do
    url "https://github.com/Kong/openresty-build-tools.git", :tag => "0.0.6"
  end

  head do
    url "https://github.com/Kong/openresty-build-tools.git"
  end

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "pcre"
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
      "--openresty #{version}",
      "--openssl 1.1.1c",
      "--luarocks 3.1.3",
      "-j #{ENV.make_jobs}"
    ]

    # Debugging mode, unfortunately without debugging symbols
    if build.with? "debug"
      args << "--debug"

      opoo "OpenResty and dependencies will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    system "./kong-ngx-build", *args

    bin.install_symlink "#{prefix}/openresty/nginx/sbin/nginx"
    bin.install_symlink "#{prefix}/openresty/bin/openresty"
    bin.install_symlink "#{prefix}/openresty/bin/resty"
    bin.install_symlink "#{prefix}/luarocks/bin/luarocks"
  end
end
