require "formula"

class NgxOpenresty < Formula
  homepage "http://openresty.org/"

  stable do
    url "http://openresty.org/download/ngx_openresty-1.7.10.2.tar.gz"
    sha256 "5e8beafb7b32ba62fd34b323b2e9cf49884b4f0491fccf189f0b88b3e25dd0e4"
    # Patch to support ssl-cert-by-lua
    # https://github.com/openresty/lua-nginx-module/issues/331#issuecomment-77279170
    patch :DATA
  end

  depends_on "openssl"
  depends_on "pcre"
  depends_on "luajit"
  depends_on "mashape/kong/luarocks_luajit"

  option "with-debug", "Compile with support for debug logging but without proper gdb debugging symbols"

  def install
    args = [
      "--prefix=#{prefix}",
      "--with-ipv6",
      "--with-luajit",
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

      opoo "OpenResty will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    # Download the ssl-cert-by-lua branch and add ssl.lua to the lua_package_path
    system "curl -s -L -o #{buildpath}/ssl-cert-by-lua.tar.gz https://github.com/openresty/lua-nginx-module/archive/ssl-cert-by-lua.tar.gz"
    system "tar -xzf ssl-cert-by-lua.tar.gz"
    system "rm -rf bundle/ngx_lua-0.9.15/*"
    system "cp -R lua-nginx-module-ssl-cert-by-lua/* bundle/ngx_lua-0.9.15/"

    system "./configure", *args
    system "make"
    system "make install"

    bin.install_symlink "#{prefix}/nginx/sbin/nginx"
  end
end

__END__
diff --exclude '*~' '--exclude=*.swp' -upr a/bundle/nginx-1.7.10/src/event/ngx_event_openssl.c b/bundle/nginx-1.7.10/src/event/ngx_event_openssl.c
--- a/bundle/nginx-1.7.10/src/event/ngx_event_openssl.c 2014-08-05 04:13:07.000000000 -0700
+++ b/bundle/nginx-1.7.10/src/event/ngx_event_openssl.c 2014-09-12 12:17:33.034582693 -0700
@@ -1121,6 +1121,21 @@ ngx_ssl_handshake(ngx_connection_t *c)
         return NGX_AGAIN;
     }

+    if (sslerr == SSL_ERROR_WANT_X509_LOOKUP) {
+        c->read->handler = ngx_ssl_handshake_handler;
+        c->write->handler = ngx_ssl_handshake_handler;
+
+        if (ngx_handle_read_event(c->read, 0) != NGX_OK) {
+            return NGX_ERROR;
+        }
+
+        if (ngx_handle_write_event(c->write, 0) != NGX_OK) {
+            return NGX_ERROR;
+        }
+
+        return NGX_AGAIN;
+    }
+
     err = (sslerr == SSL_ERROR_SYSCALL) ? ngx_errno : 0;

     c->ssl->no_wait_shutdown = 1;
diff --exclude '*~' '--exclude=*.swp' -upr a/bundle/nginx-1.7.10/src/event/ngx_event_openssl.h b/bundle/nginx-1.7.10/src/event/ngx_event_openssl.h
--- a/bundle/nginx-1.7.10/src/event/ngx_event_openssl.h 2014-08-05 04:13:07.000000000 -0700
+++ b/bundle/nginx-1.7.10/src/event/ngx_event_openssl.h 2014-09-12 12:16:32.016208272 -0700
@@ -56,6 +56,8 @@ typedef struct {
     ngx_event_handler_pt        saved_read_handler;
     ngx_event_handler_pt        saved_write_handler;

+    void                       *lua_ctx;  /* used by 3rd-party modules */
+
     unsigned                    handshaked:1;
     unsigned                    renegotiation:1;
     unsigned                    buffer:1;
