class Openresty < Formula
  homepage "https://openresty.org/"

  stable do
    url "https://openresty.org/download/openresty-1.11.2.1.tar.gz"
    sha256 "0e55b52bf6d77ac2d499ae2b05055f421acde6bb937e650ed8f482d11cbeeb5c"
  end

  depends_on "pcre"
  depends_on "openssl"

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  def install
    args = [
      "--prefix=#{prefix}",
      "--with-ipv6",
      "--with-pcre-jit",
      "--with-http_ssl_module",
      "--with-http_realip_module",
      "--with-http_stub_status_module",
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
