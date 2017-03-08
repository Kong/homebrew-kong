class Kong < Formula
  homepage "https://getkong.org"
  desc "Open source Microservices and API Gateway"

  stable do
    url "https://github.com/Mashape/kong.git", :tag => "0.10.0"
  end

  #devel do
  #  url "https://github.com/mashape/kong.git", :tag => "0.10.0rc4"
  #end

  head do
    url "https://github.com/Mashape/kong.git", :branch => "next"
  end

  depends_on "openssl"
  depends_on "dnsmasq"
  depends_on "serf"
  depends_on "mashape/kong/openresty"
  depends_on "mashape/kong/luarocks"

  def install
    system "luarocks make OPENSSL_DIR=#{Formula['openssl'].opt_prefix}"
    bin.install "bin/kong"
  end
end
