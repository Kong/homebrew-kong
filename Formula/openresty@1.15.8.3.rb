class OpenrestyAT11583 < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  version "1.15.8.3"
  kong_build_tools_version = "4.2.2"
  kong_build_tools_sha_sum = "fd4506edb39918ff615f736abbed1b42d3dfe00c3c867b9b06de73e2121e9ad6"

  # brew install kong/kong/openresty
  stable do
    url "https://github.com/Kong/kong-build-tools/archive/#{kong_build_tools_version}.zip"
    sha256 kong_build_tools_sha_sum
  end

  # brew install --HEAD kong/kong/openresty
  head do
    url "https://github.com/Kong/
/archive/master.zip"
    # No sha, since master is expected to change more frequently than this formula.
    # Will generate a warning about missing SHA while installing. That is expected and ok.
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

    # When using `brew install --HEAD ...` the version attribute
    # contains "HEAD", which is not understood by kong-ngx-build.
    # So detect that case and use the version set at the top
    # of this file (e.g. "1.15.8.2")
    openresty_version = version.head? ? self.class.version : version

    args = [
      "--prefix #{prefix}",
      "--openresty #{openresty_version}",
      "--openssl 1.1.1f",
      "--luarocks 3.3.1",
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
