class Openresty < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  kong_build_tools_version = "4.8.0"
  
  url "https://github.com/Kong/kong-build-tools/archive/#{kong_build_tools_version}.zip"

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "coreutils"
  conflicts_with "kong/kong/luarocks", :because => "We switched over to a new build method and LuaRocks no longer needs to be installed separately. Please remove it with \"brew remove kong/kong/luarocks\"."

  def install
    # dont change the openresty_version variable add a new 
    # openresty@a.b.c.d.rb file as well as a new Aliases symlink
    openresty_version = "1.15.8.3" 
    openssl_version = "1.1.1g"
    luarocks_version = "3.3.1"
    pcre_version = "8.44"
    
    # LuaJIT build is crashing in macOS Catalina. The defaults
    # for stack checks changed (they are on by default when the
    # target is 10.15). An existing issue in Clang will generate
    # code that crashes under some circumstances if stack checks
    # are enabled.
    # https://forums.developer.apple.com/thread/121887
    ENV.append_to_cflags "-fno-stack-check" if DevelopmentTools.clang_build_version >= 1010

    args = [
      "--prefix #{prefix}",
      "--openresty #{openresty_version}",
      "--openssl #{openssl_version}",
      "--luarocks #{luarocks_version}",
      "--pcre #{pcre_version}",
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
