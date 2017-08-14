class Openresty < Formula
  homepage "https://openresty.org/"

  stable do
    url "https://openresty.org/download/openresty-1.11.2.4.tar.gz"
    sha256 "07679171450a6c083f983f6130056de3c4e13cc2d117dea68e1c6990e2e49ac9"
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
      "--with-ld-opt=-L#{HOMEBREW_PREFIX}/lib,#{HOMEBREW_PREFIX}/opt/openssl/lib",
      "-j#{ENV.make_jobs}"
    ]

    # Debugging mode, unfortunately without debugging symbols
    if build.with? "debug"
      args << "--with-debug"
      args << "--with-dtrace-probes"
      args << "--with-no-pool-patch"

      opoo "OpenResty will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    system "./configure", *args
    system "make", "-j#{ENV.make_jobs}"
    system "make install"

    bin.install_symlink "#{prefix}/nginx/sbin/nginx"
  end
end
