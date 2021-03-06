class Protobuf < Formula
  desc "Protocol buffers (Google's data interchange format)"
  homepage "https://github.com/google/protobuf/"
  url "https://github.com/protocolbuffers/protobuf/releases/download/v3.12.4/protobuf-all-3.12.4.tar.gz"
  sha256 "e7bf41873d1a87c05c2b0a6197f4445c6ea3469ce0165ff14de2df8b34262530"
  head "https://github.com/google/protobuf.git"

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "6b0b5e1d6f7d0daebaad1ca3f11dc037bc76459ce252e9c1d28674209bc2841c" => :high_sierra
    sha256 "68d29d7911aaceba4b79237f086672710fa5368adb68e500a0a96094a6ce969f" => :el_capitan
  end

  # this will double the build time approximately if enabled
  option "with-test", "Run build-time check"
  option "without-python@2", "Build without python2 support"

  deprecated_option "with-check" => "with-test"
  deprecated_option "without-python" => "with-python@2"
  deprecated_option "with-python3" => "with-python"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "python@2" => :recommended
  depends_on "python" => :optional

  resource "six" do
    url "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz"
    sha256 "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259"
  end

  # Upstream's autogen script fetches this if not present
  # but does no integrity verification & mandates being online to install.
  resource "gmock" do
    url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/googlemock/gmock-1.7.0.zip"
    mirror "https://dl.bintray.com/homebrew/mirror/gmock-1.7.0.zip"
    sha256 "26fcbb5925b74ad5fc8c26b0495dfc96353f4d553492eb97e85a8a6d2f43095b"
  end

  def install
    # Don't build in debug mode. See:
    # https://github.com/Homebrew/homebrew/issues/9279
    # https://github.com/google/protobuf/blob/5c24564811c08772d090305be36fae82d8f12bbe/configure.ac#L61
    ENV.prepend "CXXFLAGS", "-DNDEBUG"
    ENV.cxx11

    (buildpath/"gmock").install resource("gmock")
    system "./autogen.sh"

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--disable-shared", "--with-zlib"
    system "make"
    system "make", "check" if build.with?("test") || build.bottle?
    system "make", "install"

    # Install editor support and examples
    doc.install "editors", "examples"

    Language::Python.each_python(build) do |python, version|
      resource("six").stage do
        system python, *Language::Python.setup_install_args(libexec)
      end
      chdir "python" do
        ENV.append_to_cflags "-I#{include}"
        ENV.append_to_cflags "-L#{lib}"
        args = Language::Python.setup_install_args libexec
        args << "--cpp_implementation"
        system python, *args
      end
      site_packages = "lib/python#{version}/site-packages"
      pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
      (prefix/site_packages/"homebrew-protobuf.pth").write pth_contents
    end
  end

  def caveats; <<~EOS
    Editor support and examples have been installed to:
      #{doc}
  EOS
  end

  test do
    testdata = <<~EOS
      syntax = "proto3";
      package test;
      message TestCase {
        string name = 4;
      }
      message Test {
        repeated TestCase case = 1;
      }
    EOS
    (testpath/"test.proto").write testdata
    system bin/"protoc", "test.proto", "--cpp_out=."
    system "python2.7", "-c", "import google.protobuf" if build.with? "python@2"
    system "python3", "-c", "import google.protobuf" if build.with? "python"
  end
end
