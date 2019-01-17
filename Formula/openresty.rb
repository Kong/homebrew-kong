class Openresty < Formula
  desc "Scalable Web Platform by Extending Nginx with Lua"
  homepage "https://openresty.org/"
  version = "1.13.6.2"
  sha_sum = "946e1958273032db43833982e2cec0766154a9b5cb8e67868944113208ff2942"

  stable do
    url "https://openresty.org/download/openresty-#{version}.tar.gz"
    sha256 sha_sum

    resource "openresty-patches" do
      url "https://github.com/Kong/openresty-patches.git", :using => :git, :shallow => false
    end
  end

  head do
    url "https://openresty.org/download/openresty-#{version}.tar.gz"
    sha256 sha_sum

    resource "openresty-patches" do
      url "https://github.com/Kong/openresty-patches.git", :using => :git, :shallow => false
    end
  end

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  depends_on "openssl@1.1"
  depends_on "pcre"

  def install
   openssl_prefix = Formula["openssl@1.1"].prefix
   pcre_prefix = Formula["pcre"].prefix

    resource("openresty-patches").stage do
      Dir["#{pwd}/patches/#{version}/*.patch"].sort.each do |f|
        cd buildpath/"bundle" do
          system "patch -p1 < #{f}"
        end
      end
    end

    args = [
      "--prefix=#{prefix}",
      "--with-pcre-jit",
      "--with-http_ssl_module",
      "--with-http_realip_module",
      "--with-http_stub_status_module",
      "--with-http_v2_module",
      "--with-stream_ssl_preread_module",
      "--with-stream_realip_module",
      "--with-cc-opt=-I#{HOMEBREW_PREFIX}/include,#{openssl_prefix}/include,#{pcre_prefix}/include",
      "--with-ld-opt=-L#{HOMEBREW_PREFIX}/lib,#{openssl_prefix}/lib,#{pcre_prefix}/lib",
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
