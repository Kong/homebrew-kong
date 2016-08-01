## Homebrew Kong Tap

Homebrew tap for [Kong] :beer:

> Kong is a scalable and customizable API Management Layer built on top of Nginx.

### Install (stable)

```shell
$ brew tap mashape/kong
$ brew install kong
```

##### Options

### Install devel (release candidates)

When a release candidate is available, it can be installed via this Formula's devel channel:

```
$ brew tap mashape/kong
$ brew install --devel kong
```

### Install HEAD (unstable)

HEAD points to Kong's `next` branch, the development branch for cutting edge installs:

```
$ brew tap mashape/kong
$ brew install --HEAD kong
```

### Use Kong

```shell
$ kong --help
```

Get started by reading the documentation at: https://getkong.org/docs.

[Kong]: https://getkong.org
