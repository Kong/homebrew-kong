require "fileutils"

class Kong < Formula
  desc "Open source Microservices and API Gateway"
  homepage "https://docs.konghq.com"
  license "Apache-2.0"

  KONG_VERSION = "3.2.2".freeze

  stable do
    url "https://github.com/Kong/kong/archive/refs/tags/#{KONG_VERSION}.tar.gz"
    sha256 "bcd85a75c5c3cbde64dbc5d11992c85ae2d934cd7c1e3bf409ec55dd61d119c9"
  end

  head do
    url "https://github.com/Kong/kong.git", branch: "master"
  end

  depends_on "automake" => :build
  depends_on "bazelisk" => :build
  depends_on "cmake" => :build
  depends_on "coreutils" => :build
  depends_on "libyaml" => :build
  depends_on "m4" => :build
  depends_on "perl" => :build
  depends_on "protobuf" => :build
  depends_on "python" => :build
  depends_on "zlib" => :build

  env :std

  patch :DATA

  # this allows .proto files to be sourced from kong's homebrew prefix when
  # combined with include.install below (trace_service.proto, etc.)
  #
  # can be removed once our luarocks supplying thier own proto files (KAG-971)
  patch :p1, <<-PATCH.gsub(/^\s{2}/, "")
    diff --git a/kong/tools/grpc.lua b/kong/tools/grpc.lua
    index 7ed532a..cd23571 100644
    --- a/kong/tools/grpc.lua
    +++ b/kong/tools/grpc.lua
    @@ -72,6 +72,7 @@ function _M.new()
         "/usr/include",
         "kong/include",
         "spec/fixtures/grpc",
    +    "HOMEBREW_PREFIX/Cellar/kong/#{KONG_VERSION}/include",
       } do
         protoc_instance:addpath(v)
       end
  PATCH

  def fix_dylib_references(install_map, executable_path)
    `otool -L #{executable_path}`.scan(/(?<=\t)(.*)(?= \(.*\n)/) do |paths|
      old_path = paths[0]
      lib_name = old_path.sub(%r{.*/}, "")
      new_path = install_map[lib_name]
      # homebrew wants us to use the macho library, but it does not work here for some reason
      system "/usr/bin/install_name_tool", "-change", old_path, new_path, executable_path if new_path
    end
  end

  def install
    tmpdir = format("%<prefix>s/kong-build.%<random>f.%<now>i",
                    prefix: ENV["HOMEBREW_TEMP"],
                    random: rand,
                    now:    Time.now.to_i)
    bazel_output_user_root = "--output_user_root=#{tmpdir}/bazel"

    # Build kong, carefully setting the environment so that brew and bazel cooperate
    python_prefix = `brew --prefix python`.strip
    coreutils_prefix = `brew --prefix coreutils`.strip
    path = ENV["PATH"]

    inreplace "kong/cmd/utils/nginx_signals.lua", "/usr/local", prefix

    with_env(
      "HOME" => "#{tmpdir}/home",
      "PATH" => "#{python_prefix}/libexec/bin:#{coreutils_prefix}/libexec/gnubin:/usr/bin:#{path}",
    ) do
      system "bazel",
             bazel_output_user_root,
             "build",
             "--config=release",
             "//build:kong",
             "--action_env=HOME",
             "--action_env=INSTALL_DESTDIR=#{prefix}",
             "--verbose_failures"
    end

    prefix.install Dir["bazel-bin/build/kong-dev/*"]
    include.install "kong/include/opentelemetry"

    bin.install "bin/kong"
    bin.install_symlink "#{prefix}/openresty/bin/resty"

    # Homebrew automatically fixes the dylib IDs of the dynamic
    # libraries it relocates, but fails to change the references in
    # them and in our executables.  Thus, we make a pass over them,
    # changing the paths to where they are installed.  A better way
    # may be to use @rpath, but that'd require changes in how we build
    # nginx which is beyond what I can do at this point.

    dylibs = Dir["#{prefix}/**/*.dylib"]

    # install_map contains a map from dylib name (i.e. foo.dylib) to installed path
    install_map = dylibs.to_h { |new_path| [new_path.sub(%r{.*/}, ""), new_path] }

    dylibs.each do |new_path|
      fix_dylib_references(install_map, new_path)
    end

    Dir["#{prefix}/**/*.so"].each do |so_file|
      chmod "u+w", so_file
      fix_dylib_references(install_map, so_file)
    end

    fix_dylib_references(install_map, "#{prefix}/openresty/nginx/sbin/nginx")
    fix_dylib_references(install_map, "#{prefix}/kong/bin/openssl")

    system "bazel", bazel_output_user_root, "clean", "--expunge"
    system "bazel", bazel_output_user_root, "shutdown"
    chmod_R "u+w", tmpdir
    rm_r tmpdir, force: true
  end

  test do
    # attempt to load .proto files using code patched above
    # "setmetatable" is required to quiet a warning
    ENV["LUA_PATH"] = [
      "#{share}/lua/5.1/?.lua;",
    ].join

    ENV["LUA_CPATH"] = [
      "#{lib}/lua/5.1/?.so",
    ].join

    system(
      "#{bin}/resty", \
      "-e", \
      <<~SCRIPT.gsub(/(^\s{6})|\n/, ""),
        require('luarocks.loader');
        setmetatable(_G,nil);
        require('kong.plugins.opentelemetry.proto')
      SCRIPT
    )

    tempfile = `gmktemp --dry-run`
    system "#{bin}/kong version -vv 2>&1 | grep 'Kong:'"
    system "#{bin}/kong", "config", "init", tempfile
    system "#{bin}/kong", "check", tempfile
  end
end

__END__
diff --git a/build/luarocks/BUILD.luarocks.bazel b/build/luarocks/BUILD.luarocks.bazel
index 2b2e960..e0c5fa1 100644
--- a/build/luarocks/BUILD.luarocks.bazel
+++ b/build/luarocks/BUILD.luarocks.bazel
@@ -65,7 +65,7 @@ OPENSSL_DIR=$$WORKSPACE_PATH/$$(echo '$(locations @openssl)' | awk '{print $$1}'

 # we use system libyaml on macos
 if [[ "$$OSTYPE" == "darwin"* ]]; then
-    YAML_DIR=$$(brew --prefix)/opt/libyaml
+    YAML_DIR=HOMEBREW_PREFIX/opt/libyaml
 elif [[ -d $$WORKSPACE_PATH/$(BINDIR)/external/cross_deps_libyaml/libyaml ]]; then
     # TODO: is there a good way to use locations but doesn't break non-cross builds?
     YAML_DIR=$$WORKSPACE_PATH/$(BINDIR)/external/cross_deps_libyaml/libyaml
diff --git a/bin/kong b/bin/kong
--- a/bin/kong
+++ b/bin/kong
@@ -4,6 +4,7 @@ setmetatable(_G, nil)

 pcall(require, "luarocks.loader")
 
-package.path = (os.getenv("KONG_LUA_PATH_OVERRIDE") or "") .. "./?.lua;./?/init.lua;" .. package.path
+package.cpath = (os.getenv("KONG_LUA_CPATH_OVERRIDE") or "") .. "HOMEBREW_PREFIX/lib/lua/5.1/?.so;" .. package.cpath
+package.path = (os.getenv("KONG_LUA_PATH_OVERRIDE") or "") .. "./?.lua;./?/init.lua;" .. "HOMEBREW_PREFIX/share/lua/5.1/?.lua;HOMEBREW_PREFIX/share/lua/5.1/?/init.lua;" .. package.path
 
 require("kong.cmd.init")(arg)
diff --git a/kong/templates/kong_defaults.lua b/kong/templates/kong_defaults.lua
--- a/kong/templates/kong_defaults.lua
+++ b/kong/templates/kong_defaults.lua
@@ -1,5 +1,5 @@
 return [[
-prefix = /usr/local/kong/
+prefix = HOMEBREW_PREFIX/opt/kong/
 log_level = notice
 proxy_access_log = logs/access.log
 proxy_error_log = logs/error.log
@@ -166,8 +166,8 @@ lua_socket_pool_size = 30
 lua_ssl_trusted_certificate = NONE
 lua_ssl_verify_depth = 1
 lua_ssl_protocols = TLSv1.1 TLSv1.2 TLSv1.3
-lua_package_path = ./?.lua;./?/init.lua;
-lua_package_cpath = NONE
+lua_package_path = ./?.lua;./?/init.lua;HOMEBREW_PREFIX/share/lua/5.1/?.lua;HOMEBREW_PREFIX/share/lua/5.1/?/init.lua;;
+lua_package_cpath = HOMEBREW_PREFIX/lib/lua/5.1/?.so;;
 
 role = traditional
 kic = off
diff -r -u a/kong/cmd/prepare.lua b/kong/cmd/prepare.lua
--- a/kong/cmd/prepare.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/cmd/prepare.lua	2022-09-15 10:53:58.000000000 +0200
@@ -23,8 +23,8 @@

 Example usage:
  kong migrations up
- kong prepare -p /usr/local/kong -c kong.conf
- nginx -p /usr/local/kong -c /usr/local/kong/nginx.conf
+ kong prepare -p HOMEBREW_PREFIX -c kong.conf
+ nginx -p HOMEBREW_PREFIX -c HOMEBREW_PREFIX/nginx.conf

 Options:
  -c,--conf       (optional string) configuration file
diff -r -u a/kong/pdk/init.lua b/kong/pdk/init.lua
--- a/kong/pdk/init.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/pdk/init.lua	2022-09-15 10:54:21.000000000 +0200
@@ -49,7 +49,7 @@
 --
 -- @field kong.configuration
 -- @usage
--- print(kong.configuration.prefix) -- "/usr/local/kong"
+-- print(kong.configuration.prefix) -- "HOMEBREW_PREFIX"
 -- -- this table is read-only; the following throws an error:
 -- kong.configuration.prefix = "foo"

diff -r -u a/kong/runloop/plugin_servers/process.lua b/kong/runloop/plugin_servers/process.lua
--- a/kong/runloop/plugin_servers/process.lua	2022-09-12 14:38:55.000000000 +0200
+++ b/kong/runloop/plugin_servers/process.lua	2022-09-15 10:54:10.000000000 +0200
@@ -61,7 +61,7 @@
       local env_prefix = "pluginserver_" .. name:gsub("-", "_")
       _servers[i] = {
         name = name,
-        socket = config[env_prefix .. "_socket"] or "/usr/local/kong/" .. name .. ".socket",
+        socket = config[env_prefix .. "_socket"] or "HOMEBREW_PREFIX/" .. name .. ".socket",
         start_command = config[env_prefix .. "_start_cmd"] or ifexists("/usr/local/bin/"..name),
         query_command = config[env_prefix .. "_query_cmd"] or ifexists("/usr/local/bin/query_"..name),
       }
