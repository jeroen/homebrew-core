class OpenOcd < Formula
  desc "On-chip debugging, in-system programming and boundary-scan testing"
  homepage "https://sourceforge.net/projects/openocd/"
  url "https://downloads.sourceforge.net/project/openocd/openocd/0.10.0/openocd-0.10.0.tar.bz2"
  sha256 "7312e7d680752ac088b8b8f2b5ba3ff0d30e0a78139531847be4b75c101316ae"

  bottle do
    rebuild 1
#    sha256 "5737d38a9129d824cd40116c4f678d1dd93cff4ae1de6177e4cedcb93d2b34cd" => :mojave
    sha256 "eab0153f54c97d4922386996d7517b6dc22c8e418b620ba42dd6f190fc0c48f7" => :high_sierra
    sha256 "281978e21362ed00dd198715825d77f0f2aeb64ad99954714a34ce128e1a0df8" => :sierra
    sha256 "e1fc5f8a8bf079954a56459b330313cd82a69a219114821c14f9d3df2fd3ea25" => :el_capitan
    sha256 "568ae702a3488805b8651b5456346c9484ca6f8486a09f3c2a4473664370a481" => :yosemite
  end

  head do
    url "https://git.code.sf.net/p/openocd/code.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "texinfo" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "hidapi"
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  def install
    ENV["CCACHE"] = "none"

    system "./bootstrap", "nosubmodule" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-buspirate",
                          "--enable-dummy",
                          "--enable-jtag_vpi",
                          "--enable-remote-bitbang"
    system "make", "install"
  end
end
