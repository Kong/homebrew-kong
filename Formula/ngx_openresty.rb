class NgxOpenresty < Formula
  homepage "http://openresty.org/"

  stable do
    url "https://openresty.org/download/openresty-1.9.7.4.tar.gz"
    sha256 "aa5dcae035dda6e483bc1bd3d969d7113205dc2d0a3702ece0ad496c88a653c5"
  end

  depends_on "openssl"
  depends_on "pcre"
  depends_on "mashape/kong/luajit"
  depends_on "mashape/kong/luarocks"

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  def install
    luajit = Formula["mashape/kong/luajit"]

    args = [
      "--prefix=#{prefix}",
      "--with-ipv6",
      "--with-pcre-jit",
      "--with-http_ssl_module",
      "--with-http_realip_module",
      "--with-http_stub_status_module",
      "--with-luajit=#{luajit.prefix}",
      "--with-cc-opt=-I#{HOMEBREW_PREFIX}/include",
      "--with-ld-opt=-L#{HOMEBREW_PREFIX}/lib"
    ]

    # Debugging mode, unfortunately without debugging symbols
    if build.with? "debug"
      args << "--with-debug"
      args << "--with-dtrace-probes"
      args << "--with-no-pool-patch"

      opoo "OpenResty will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    system "./configure", *args
    system "make"
    system "make install"

    bin.install_symlink "#{prefix}/nginx/sbin/nginx"
  end
end
