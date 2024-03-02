[settings]
arch=x86_64
build_type=Release
compiler=gcc
compiler.cppstd=gnu17
compiler.libcxx=libstdc++11
compiler.version=13
os=Linux

[conf]
tools.cmake.cmaketoolchain:user_toolchain=["{{ os.path.join(profile_dir, "x86_64-centos7-linux-gnu.toolchain.cmake") }}"]
tools.gnu:host_triplet="x86_64-centos7-linux-gnu"
tools.build:sysroot="{{ os.path.join(profile_dir, "x-tools/x86_64-centos7-linux-gnu/x86_64-centos7-linux-gnu/sysroot") }}"
tools.build:cflags=[]
tools.build:cxxflags=[]
tools.build:compiler_executables={ "c": "{{ os.path.join(profile_dir, "x-tools/x86_64-centos7-linux-gnu/bin/x86_64-centos7-linux-gnu-gcc") }}", "cpp": "{{ os.path.join(profile_dir, "x-tools/x86_64-centos7-linux-gnu/bin/x86_64-centos7-linux-gnu-g++") }}", "fortran": "{{ os.path.join(profile_dir, "x-tools/x86_64-centos7-linux-gnu/bin/x86_64-centos7-linux-gnu-gfortran") }}" }
