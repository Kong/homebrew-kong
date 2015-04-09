## Homebrew Kong Tap

Homebrew tap for [Kong] :beer:

> Kong is a scalable and customizable API Management Layer built on top of Nginx.

## Install

```
$ brew tap thibaultcha/kong
$ brew install kong
```

##### Options

###### Install Cassandra

If you want to use a local Cassandra cluster, this tap can also install the homebrew/cassandra formula if you run it with:

```
$ brew update # for the cassandra formula
$ brew install kong --with-cassandra
```

## Use Kong

```
$ kong -h
```

Kong's documentation is available at: http://getkong.org/docs.

[Kong]: http://getkong.org
