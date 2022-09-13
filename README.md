# Homebrew Kong Tap

Homebrew tap for [Kong] :beer:

> Kong is a scalable and customizable API Management Layer built on top of
> Nginx.

## Install (stable)

```shell
$ brew tap kong/kong
==> Tapping kong/kong
Cloning into '/usr/local/Homebrew/Library/Taps/kong/homebrew-kong'...
<snip>

$ brew install kong
==> Downloading https://github.com/Kong/kong-build-tools/archive/4.22.0.tar.gz
==> Downloading https://download.konghq.com/gateway-src/kong-2.8.1.tar.gz
<snip>
```

## Options

### Install HEAD (unstable)

HEAD points to Kong's `next` branch, the development branch for cutting edge
installs:

```shell
$ brew install --HEAD kong
==> Downloading https://github.com/Kong/kong-build-tools/archive/4.22.0.tar.gz
==> Downloading from https://codeload.github.com/Kong/kong-build-tools/tar.gz/refs/tags/4.22.0
==> Cloning https://github.com/Kong/kong.git
Cloning into '/Users/if/Library/Caches/Homebrew/kong--git'...
==> Checking out branch master
==> Installing kong from kong/kong
==> Installing dependencies for kong/kong/kong: kong/kong/openresty@1.19.3.2
==> Installing kong/kong/kong dependency: kong/kong/openresty@1.19.3.2
<snip>
```

### Removing the Tap

```shell
$ brew untap kong/kong
Untapping kong/kong...
Untapped 6 formulae (23 files, 198.8KB).
```

## Developing Formulae

### Use a branch/tag of this tap

Developing formulae can be eased by setting a git ref (branch/tag) for the entire tap. This can be accomplished by tapping the tap, then using `git checkout` to arrive at the desired ref (for all formulae):

```shell
$ brew tap kong/kong
==> Tapping kong/kong
<snip>

$ cd /usr/local/Homebrew/Library/Taps/kong/homebrew-kong

$ git checkout release/3.0.0
Branch 'release/3.0.0' set up to track remote branch 'release/3.0.0' from 'origin'.
Switched to a new branch 'release/3.0.0'

$ brew install kong
==> Downloading https://github.com/Kong/kong-build-tools/archive/4.33.10.tar.gz
==> Downloading https://download.konghq.com/gateway-src/kong-3.0.0.tar.gz
==> Installing kong from kong/kong
==> Installing dependencies for kong/kong/kong: kong/kong/openresty@1.21.4.1
==> Installing kong/kong/kong dependency: kong/kong/openresty@1.21.4.1
<snip>
```

Get the full output from the `kong-ngx-build` script by using the `--verbose` flag when installing:

```shell
$ brew install --verbose kong
<snip>
==> ./kong-ngx-build --prefix /usr/local/Cellar/openresty@1.21.4.1/1.21.4.1 --openresty 1.21.4.1 --openssl 1.1.1q --luarocks 3.9.1 --pcre 8.45 -j 12
NOTICE: Downloading the components now...
/private/tmp/openrestyA1.21.4.1-20220913-30100-7mtl7u/kong-build-tools-4.33.10/openresty-build-tools/work /private/tmp/openrestyA1.21.4.1-20220913-30100-7mtl7u/kong-build-tools-4.33.10/openresty-build-tools
WARN: OpenSSL source not found, downloading...
NOTICE: Downloaded: d7939ce614029cdff0b6c20f0e2e5703158a489a72b2507b8bd51bf8c8fd10ca  openssl-1.1.1q.tar.gz
<snip>
```

Run the tests that live in the formulae (after installing them):

```shell
$ brew test --verbose kong
==> Testing kong/kong/kong
/usr/local/Homebrew/Library/Homebrew/test.rb (Formulary::FromPathLoader): loading /usr/local/Homebrew/Library/Taps/kong/homebrew-kong/Formula/kong.rb
==> /usr/local/Cellar/kong/3.0.0/bin/kong version -vv 2>&1 | grep 'Kong:'
2022/09/13 11:42:04 [verbose] Kong: 3.0.0
==> kong config init /private/tmp/tmp.DYgJNwy8Xa
==> kong check /private/tmp/tmp.DYgJNwy8Xa
configuration at /private/tmp/tmp.DYgJNwy8Xa
 is valid
```

## Use Kong

```shell
$ KONG_DATABASE=off kong start
Kong started
```

Get started by reading the documentation at: [https://docs.konghq.com](https://docs.konghq.com)

[kong]: https://konghq.com
