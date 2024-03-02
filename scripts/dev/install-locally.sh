#!/usr/bin/env bash
cd "$( dirname "${BASH_SOURCE[0]}" )"/../..

set -ex

# Select architecture
triple="x86_64-centos7-linux-gnu"

# Download compiler
download_url="https://github.com/tttapa/cross-python/releases/download/0.1.2"
tools_dir="$PWD/toolchains"
pfx="$tools_dir/$triple"
mkdir -p "$tools_dir"
if [ ! -d "$pfx" ]; then
    wget "$download_url/full-$triple.tar.xz" -O- | \
        tar xJ -C "$tools_dir"
fi

# Use ccache to cache compilation
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
# Compile for this system's processor for optimal performance
export CFLAGS="-march=native -fdiagnostics-color"
export CXXFLAGS="-march=native -fdiagnostics-color"
export FCFLAGS="-march=native -fdiagnostics-color"
export LDFLAGS="-static-libstdc++"

# Build Python package
config="$triple.py-build-cmake.config.toml"
cat <<- EOF > "$config"
[cmake]
generator = "Ninja Multi-Config"
config = ["Release","Debug"]
[cmake.options]
CMAKE_FIND_ROOT_PATH = "$pfx/pybind11-master;$pfx/eigen-master"
USE_GLOBAL_PYBIND11 = "On"
EOF
pip install -U pip build
develop=false
if $develop; then
    LDFLAGS='-static-libstdc++' \
    pip install -e ".[test]" -v \
        --config-settings=--cross="$pfx/$triple.py-build-cmake.cross.toml" \
        --config-settings=--local="$PWD/$config"
else
    LDFLAGS='-static-libstdc++' \
    python -m build -w "." -o staging \
        -C--cross="$pfx/$triple.py-build-cmake.cross.toml" \
        -C--local="$PWD/$config"
    LDFLAGS='-static-libstdc++' \
    python -m build -w "QPALM/interfaces/python/qpalm-debug" -o staging \
        -C--cross="$pfx/$triple.py-build-cmake.cross.toml" \
        -C--local="$PWD/$config"
    pip install -f staging --force-reinstall --no-deps \
        "qpalm==1.2.3.dev1" "qpalm-debug==1.2.3.dev1"
    pip install -f staging \
        "qpalm[test]==1.2.3.dev1" "qpalm-debug==1.2.3.dev1"
fi
pytest