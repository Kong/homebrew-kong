require "formula"

class NgxOpenresty < Formula
  homepage "http://openresty.org/"
  url "http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz"
  sha1 "0cc7a3fe75fbe50dec619af1a09b87f7f8c79e1d"

  depends_on "pcre"
  depends_on "luajit"

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  def install
    args = [
      "--prefix=#{prefix}",
      "--with-ipv6",
      "--with-pcre-jit",
      "--with-http_ssl_module",
      "--with-http_realip_module",
      "--with-http_stub_status_module",
      "--with-cc-opt=-I#{HOMEBREW_PREFIX}/include",
      "--with-ld-opt=-L#{HOMEBREW_PREFIX}/lib"
    ]

    # Debugging mode, unfortunately without debugging symbols
    if build.with? "debug"
      args << "--with-debug"
      args << "--with-dtrace-probes"
      args << "--with-no-pool-patch"

      opoo "Openresty will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    system "./configure", *args

    system "make"
    system "make install"
  end
end
