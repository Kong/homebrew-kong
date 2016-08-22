class Kong < Formula
  homepage "https://getkong.org"
  desc "Open-source Microservice and API Gateway"

  stable do
    url "https://github.com/Mashape/kong.git", :tag => "0.9.0"
  end

  #devel do
    #url "https://github.com/mashape/kong.git", :tag => "0.9.0rc3"
  #end

  head do
    url "https://github.com/Mashape/kong.git", :branch => "next"
  end

  depends_on "serf"
  depends_on "openssl"
  depends_on "dnsmasq"
  depends_on "mashape/kong/luarocks"
  depends_on "mashape/kong/ngx_openresty"

  conflicts_with "cassandra", :because => "Kong only supports Cassandra 2.1/2.2"

  def install
    system "luarocks make OPENSSL_DIR=#{Formula['openssl'].opt_prefix}"
    bin.install "bin/kong"
  end
end
