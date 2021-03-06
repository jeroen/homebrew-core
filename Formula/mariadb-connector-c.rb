class MariadbConnectorC < Formula
  desc "MariaDB database connector for C applications"
  homepage "https://downloads.mariadb.org/connector-c/"
  url "https://downloads.mariadb.org/f/connector-c-3.1.11/mariadb-connector-c-3.1.11-src.tar.gz"
  mirror "https://fossies.org/linux/misc/mariadb-connector-c-3.1.11-src.tar.gz"
  sha256 "3e6f6c399493fe90efdc21a3fe70c30434b7480e8195642a959f1dd7a0fa5b0f"
  head "https://github.com/mariadb-corporation/mariadb-connector-c.git", :branch => 3.1

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "4da246554950bbf134c7c2ea1bd62c4f3035703ebbb80f636bb1eac4f57c025f" => :high_sierra
    sha256 "4e5eef09c84c7f43957393d765deadc7f5d7e18ae444874ba97ad753438ef5b0" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  conflicts_with "mysql", "mariadb", "percona-server",
                 :because => "both install plugins"

  def install
    args = std_cmake_args
    args << "-DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT=STATIC"
    args << "-DCLIENT_PLUGIN_DIALOG=STATIC"
    args << "-DCLIENT_PLUGIN_CLIENT_ED25519=STATIC"
    args << "-DCLIENT_PLUGIN_CACHING_SHA2_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_SHA256_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_MYSQL_CLEAR_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_MYSQL_OLD_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_REMOTE_IO=OFF"

    ENV["CFLAGS"] = "-DMYSQL_CLIENT=1"
    ENV["OPENSSL_ROOT_DIR"] = "/usr/local/opt/openssl@1.1"

    mkdir "build" do
      system "/usr/local/bin/cmake", "..", *args
      system "make", "install", "-j1"
    end
  end

  test do
    system "#{bin}/mariadb_config", "--cflags"
  end
end
