## Homebrew Kong Tap

Homebrew tap for [Kong] :beer:

> Kong is a scalable and customizable API Management Layer built on top of Nginx.

## Install (stable)

```shell
$ brew tap mashape/kong
$ brew install kong
```

##### Options

## Install HEAD (unstable)

```
$ brew tap mashape/kong
$ brew install kong --HEAD
```

## Use Kong

```shell
$ kong --help
```

Get started by reading the documentation at: http://getkong.org/docs.

## Troubleshooting

```
Could not find expected file openssl/ssl.h, or openssl/ssl.h for OPENSSL -- you may have to install OPENSSL in your system and/or pass OPENSSL_DIR or OPENSSL_INCDIR to the luarocks command. Example: luarocks install luasec OPENSSL_DIR=/usr/local
```

Make sure you have installed `openssl` from Homebrew and that is is linked (`brew link --force openssl`).

[Kong]: http://getkong.org
