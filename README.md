## Homebrew Kong Tap

Homebrew tap for [Kong] :beer:

> Kong is a scalable and customizable API Management Layer built on top of Nginx.

### Install (stable)

```shell
$ brew tap mashape/kong
$ brew install kong
```

##### Options

### Install devel

devel points to the latest Release Candidate of Kong.

```
$ brew tap mashape/kong
$ brew install --devel kong
```

**Note**: the current `0.6.0rc3` release of Kong also requires Serf. You can install Serf with:

```
$ brew cask install serf
```

### Install HEAD (unstable)

HEAD points to Kong's `next` branch, the development branch for cutting edge installs.

```
$ brew tap mashape/kong
$ brew install kong --HEAD
```

### Use Kong

```shell
$ kong --help
```

Get started by reading the documentation at: http://getkong.org/docs.

### Troubleshooting

```
Could not find expected file openssl/ssl.h, or openssl/ssl.h for OPENSSL -- you may have to install OPENSSL in your system and/or pass OPENSSL_DIR or OPENSSL_INCDIR to the luarocks command. Example: luarocks install luasec OPENSSL_DIR=/usr/local
```

Make sure you have installed `openssl` from Homebrew and that is is linked (`brew link --force openssl`).

[Kong]: http://getkong.org
