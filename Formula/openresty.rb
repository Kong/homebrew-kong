class Openresty < Formula
  homepage "https://openresty.org/"
  version = "1.13.6.1"
  sha_sum = "d1246e6cfa81098eea56fb88693e980d3e6b8752afae686fab271519b81d696b"

  stable do
    url "https://openresty.org/download/openresty-#{version}.tar.gz"
    sha256 sha_sum

    resource "openresty-patches" do
      url "https://github.com/Kong/openresty-patches.git", :using => :git, :shallow => false
    end
  end

  depends_on "pcre"
  depends_on "openssl"

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  def install
    resource("openresty-patches").stage do
      Dir["#{pwd}/patches/#{version}/*.patch"].each do |f|
        system "cd", buildpath/"bundle", "&&", "patch", "-p1", "<", f
      end
    end

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
