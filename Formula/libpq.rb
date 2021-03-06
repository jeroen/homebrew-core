class Libpq < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/12/libpq.html"
  url "https://ftp.postgresql.org/pub/source/v13.1/postgresql-13.1.tar.bz2"
  sha256 "12345c83b89aa29808568977f5200d6da00f88a035517f925293355432ffe61f"

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "e1c99b95b36b4e55adce0177bfd51d2705b97a20d16cdcc983a07e3ca759b3b5" => :el_capitan
    sha256 "b5aa5f9f5dbde79be847f193d26d3b9d1d4461cb7c9223db21d0a75fd8c5bdbd" => :high_sierra
  end

  keg_only "conflicts with postgres formula"

  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  # depends_on "krb5"

  depends_on "openssl@1.1"

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-gssapi",
                          "--with-openssl",
                          "--libdir=#{opt_lib}",
                          "--includedir=#{opt_include}"
    dirs = %W[
      libdir=#{lib}
      includedir=#{include}
      pkgincludedir=#{include}/postgresql
      includedir_server=#{include}/postgresql/server
      includedir_internal=#{include}/postgresql/internal
    ]
    system "make"
    system "make", "-C", "src/bin", "install", *dirs
    system "make", "-C", "src/include", "install", *dirs
    system "make", "-C", "src/interfaces", "install", *dirs
    system "make", "-C", "src/common", "install", *dirs
    system "make", "-C", "src/port", "install", *dirs
    system "make", "-C", "doc", "install", *dirs
  end

  test do
    (testpath/"libpq.c").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      #include <libpq-fe.h>
      int main()
      {
          const char *conninfo;
          PGconn     *conn;
          conninfo = "dbname = postgres";
          conn = PQconnectdb(conninfo);
          if (PQstatus(conn) != CONNECTION_OK) // This should always fail
          {
              printf("Connection to database attempted and failed");
              PQfinish(conn);
              exit(0);
          }
          return 0;
        }
    EOS
    system ENV.cc, "libpq.c", "-L#{lib}", "-I#{include}", "-lpq", "-o", "libpqtest"
    assert_equal "Connection to database attempted and failed", shell_output("./libpqtest")
  end
end
