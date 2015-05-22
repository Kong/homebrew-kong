## Homebrew Kong Tap

Homebrew tap for [Kong] :beer:

> Kong is a scalable and customizable API Management Layer built on top of Nginx.

## Install (stable)

```shell
$ brew tap mashape/kong
$ brew install kong
```

##### Options

###### Install Cassandra

If you want to use a local Cassandra cluster, this tap can also install the homebrew/cassandra formula if you run it with:

```shell
$ brew update # for the cassandra formula
$ brew install kong --with-cassandra
```

## Install HEAD (unstable)

```
$ brew tap mashape/kong
$ brew install kong --HEAD
```

**Note:** To install Kong `0.3.0` (current `HEAD`), a patch on OpenResty is needed to support the `ssl_cert_by_lua` directive:

```shell
$ brew install mashape/ngx_openresty --devel
$ brew install kong --HEAD
```

## Use Kong

```shell
$ kong --help
```

Get started by reading the documentation at: http://getkong.org/docs.

[Kong]: http://getkong.org
