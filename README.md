## Homebrew Kong Tap

Homebrew tap for [Kong](kong-url).

> Kong is a scalable and customizable API Management Layer built on top of Nginx.

## Install

```
$ brew tap thibaultcha/kong
$ brew install kong
```

###### Install with Cassandra

If you want to use a local Cassandra cluster, this tap can also install cassandra if you run it with:

```
$ brew install kong --with-cassandra
```

## Use Kong

```
$ kong -h
```

Kong's documentation is available at: http://getkong.org/docs.

[kong-url]: http://getkong.org
