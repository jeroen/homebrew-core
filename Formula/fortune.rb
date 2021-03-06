class Fortune < Formula
  desc "Infamous electronic fortune-cookie generator"
  homepage "https://www.ibiblio.org/pub/linux/games/amusements/fortune/!INDEX.html"
  url "https://www.ibiblio.org/pub/linux/games/amusements/fortune/fortune-mod-9708.tar.gz"
  mirror "https://src.fedoraproject.org/repo/pkgs/fortune-mod/fortune-mod-9708.tar.gz/81a87a44f9d94b0809dfc2b7b140a379/fortune-mod-9708.tar.gz"
  sha256 "1a98a6fd42ef23c8aec9e4a368afb40b6b0ddfb67b5b383ad82a7b78d8e0602a"

  bottle do
    rebuild 2
#    sha256 "d85c1636ea7ca0345d390e63e32f8cccb5f10c881a88477ecc4b8ad99cbb8be2" => :mojave
    sha256 "6f8a87247d72ed1d9197370b1df307bdb9d949d868ae210b7dc32dc43eaba8ab" => :high_sierra
    sha256 "ac140349dc3a0ce55d2299e90651492df8ccf7839f57d8b1fa6ca221a665efc7" => :sierra
    sha256 "fe681ea371ce058faeebbd459ac9b5f492b7b523652da937ed8cb7d9bbf0eaf8" => :el_capitan
    sha256 "97c35357e5becf525ddaede462e40283872d0b5d2cebfeeb7d509cb0ef06fc7c" => :yosemite
    sha256 "61792a39fce2c81cf7a47a9230884d0bc19ff7c5f84bc7264f2bc0aa705f8eb1" => :mavericks
  end

  option "without-offensive", "Don't install potentially offensive fortune files"

  deprecated_option "no-offensive" => "without-offensive"

  def install
    ENV.deparallelize

    inreplace "Makefile" do |s|
      # Use our selected compiler
      s.change_make_var! "CC", ENV.cc

      # Change these first two folders to the correct location in /usr/local...
      s.change_make_var! "FORTDIR", "/usr/local/bin"
      s.gsub! "/usr/local/man", "/usr/local/share/man"
      # Now change all /usr/local at once to the prefix
      s.gsub! "/usr/local", prefix

      # macOS only supports POSIX regexes
      s.change_make_var! "REGEXDEFS", "-DHAVE_REGEX_H -DPOSIX_REGEX"
      # Don't install offensive fortunes
      s.change_make_var! "OFFENSIVE", "0" if build.without? "offensive"
    end

    system "make", "install"
  end

  test do
    system "#{bin}/fortune"
  end
end
