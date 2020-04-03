%define     tf_version    2.0.0
Name:       tensorflow
Summary:    Tensorflow
Version:    v2.0.0
Release:    1
License:    Apache-2.0
Source0:    %{name}-%{version}.tar.gz
Source1001:     tensorflow.manifest
Source1002:     gcc_version_check.c

# Exclusively for tf-lite
Source30000:    absl-43ef2148c0936ebf7cb4be6b19927a9d9d145b8f.tar.gz
Source30010:    eigen-049af2f56331.tar.gz
Source30020:    farmhash-816a4ae622e964763ca0862d9dbd19324a1eaf45.tar.gz
Source30030:    fft2d.tar.gz
Source30040:    gemmlowp-12fed0cd7cfcd9e169bf1925bc3a7a58725fdcc3.tar.gz
Source30050:    googletest-release-1.8.0.tar.gz
Source30060:    neon_2_sse-master.tar.gz

Source4001:     0001-Lite-Make-Use-the-system-library-for-flatbuffers.patch
Source4002:     tensorflow-lite.pc.in

BuildRequires:  zlib-devel-static
BuildRequires:  flatbuffers-devel

%description
TensorFlow is an open source software library for numerical computation using
data flow graphs. Nodes in the graph represent mathematical operations, while
the graph edges represent the multidimensional data arrays (tensors)
communicated between them. The flexible architecture allows you to deploy
computation to one or more CPUs or GPUs in a desktop, server, or mobile device
with a single API. TensorFlow was originally developed by researchers and
engineers working on the Google Brain Team within Google's Machine Intelligence
research organization for the purposes of conducting machine learning and deep
neural networks research, but the system is general enough to be applicable in
a wide variety of other domains as well.

%package -n tensorflow-lite-devel
Summary: Tensorflow Lite development headers and object file

Requires:  flatbuffers-devel

%description -n tensorflow-lite-devel
Tensorflow Lite development headers and object file

%prep
%setup -q
cp %{SOURCE4001} .
# local patch
cat 0001-Lite-Make-Use-the-system-library-for-flatbuffers.patch | patch -p1 --fuzz=2
# .manifest
cp %{SOURCE1002} .

# External dependencies (except flatbuffers) for TensorFlow Lite
# In the case of flatbuffers, use the system library
# 00. Abseil Common Libraries (C++)
cp %{SOURCE30000} .
# 10. libeigen
cp %{SOURCE30010} .
# 20. farmhash
cp %{SOURCE30020} .
# 30. fft2d
cp %{SOURCE30030} .
# 40. gemmlowp: a small self-contained low-precision GEMM library
cp %{SOURCE30040} .
# 50. googletest
cp %{SOURCE30050} .
# 60. ARM_NEON_2_x86_SSE
cp %{SOURCE30060} .
cat *.tar.gz | tar zxf - -i

%build
export PATH=${PATH}:`pwd`

%ifarch %arm
CFLAGS="${CFLAGS} -DARM_NON_MOBILE -mfpu=neon -mno-unaligned-access"
CXXFLAGS="${CXXFLAGS} -DARM_NON_MOBILE -mfpu=neon -mno-unaligned-access"
%endif

CFLAGS="${CFLAGS} -fPIC"
CXXFLAGS="${CXXFLAGS} -fPIC"

cp %{SOURCE1002} .
gcc gcc_version_check.c -Wno-error=class-memaccess && export CFLAGS="$CFLAGS -Wno-error=class-memaccess" && export CXXFLAGS="$CXXFLAGS -Wno-error=class-memaccess" && echo "Applying Wno-error=class-memaccess"|| echo "OLD GCC. Don't Add Wno-error=class-memaccess"

# Downgrade compiler flags for google code.
CFLAGS=`echo $CFLAGS | sed -e "s|-Wformat-security||"`
CXXFLAGS=`echo $CXXFLAGS | sed -e "s|-Wformat-security||"`
EXTRA_CFLAGS=`echo $CFLAGS | sed -e "s|-Wall|-Wno-sign-compare -Wno-unused-but-set-variable -Wno-format-security -Wno-format -Wno-psabi|"`
EXTRA_CXXFLAGS=`echo $CXXFLAGS | sed -e "s|-Wall|-Wno-sign-compare -Wno-unused-but-set-variable -Wno-format-security -Wno-format -Wno-psabi|"`

# build tensorflow lite
%ifarch %arm aarch64
make -f tensorflow/lite/tools/make/Makefile TARGET=TIZEN TARGET_ARCH=%{_target_cpu} CXXFLAGS="${EXTRA_CXXFLAGS} -D__ARM_NEON" CFLAGS="${EXTRA_CFLAGS} -D__ARM_NEON"
%else
make -f tensorflow/lite/tools/make/Makefile TARGET=TIZEN TARGET_ARCH=%{_target_cpu} CXXFLAGS="${EXTRA_CXXFLAGS}" CFLAGS="${EXTRA_CFLAGS}"
%endif

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%install
# install for tensorflow lite
mkdir -p %{buildroot}%{_libdir}
mkdir -p %{buildroot}%{_libdir}/pkgconfig

cp %{SOURCE4002} .
sed -i 's:@libdir@:%{_libdir}:g
    s:@includedir@:%{_includedir}:g
    s:@version@:%{tf_version}:g' ./tensorflow-lite.pc.in

install -m 0644 tensorflow/lite/tools/make/gen/TIZEN_%{_target_cpu}/lib/libtensorflow-lite.a %{buildroot}%{_libdir}/
install -m 0644 ./tensorflow-lite.pc.in %{buildroot}%{_libdir}/pkgconfig/tensorflow-lite.pc

pushd tensorflow/lite
rm -rf tools/make/downloads
find . -name "*.h" -exec dirname {} \; | cut -c2- | uniq | xargs -n 1 -I {} mkdir -p %{buildroot}%{_includedir}/tensorflow/lite/{}
find . -name "*.h" -exec cp {} %{buildroot}%{_includedir}/tensorflow/lite/{} \;
popd

# For backward compatibility with v1.09, where tf-lite was in contrib
mkdir -p %{buildroot}%{_includedir}/tensorflow/contrib
ln -sf %{_includedir}/tensorflow/lite %{buildroot}%{_includedir}/tensorflow/contrib/lite

%files -n tensorflow-lite-devel
%{_libdir}/libtensorflow-lite.a
%{_libdir}/pkgconfig/tensorflow-lite.pc
%{_includedir}/*
