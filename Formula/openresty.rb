class Openresty < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  version "1.15.8.1"
  kong_ngx_build_version = "0.0.5"
  kong_ngx_build_sha_sum = "9ed2a6468ecfc976d8f3468ce6a138a05f375a2b65e858183f90d84f761bca34"

  stable do
    url "https://raw.githubusercontent.com/Kong/openresty-build-tools/#{kong_ngx_build_version}/kong-ngx-build"
    sha256 kong_ngx_build_sha_sum
  end

  head do
    url "https://raw.githubusercontent.com/Kong/openresty-build-tools/#{kong_ngx_build_version}/kong-ngx-build"
    sha256 kong_ngx_build_sha_sum
  end

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "pcre"
  depends_on "coreutils"
  conflicts_with "kong/kong/luarocks", :because => "We switched over to a new build method and LuaRocks no longer needs to be installed separately. Please remove it with \"brew remove kong/kong/luarocks\"."

  def install
    chmod 0755, "#{pwd}/kong-ngx-build"

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
