class NgxOpenresty < Formula
  homepage "http://openresty.org/"

  stable do
    url "https://openresty.org/download/openresty-1.9.15.1.tar.gz"
    sha256 "75cf020144048c9013ee487cb48107a5b99de04a5a8fa83839c8b4c3aa4eb0db"
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
      "--with-cc-opt=-I#{HOMEBREW_PREFIX}/include,#{HOMEBREW_PREFIX}/opt/openssl/include",
      "--with-ld-opt=-L#{HOMEBREW_PREFIX}/lib,#{HOMEBREW_PREFIX}/opt/openssl/lib"
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

    bin.install "#{prefix}/nginx/sbin/nginx"
  end
end
