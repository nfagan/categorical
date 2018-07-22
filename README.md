# categorical

`categorical` is meant to quickly generate indices of subsets of data. Observations of data are associated with labels, divided into categories, enabling the fast lookup of single labels and label combinations.

### dependencies (main library)
* c++14 compatible compiler.
* cmake

### dependencies (matlab api)
* matlab >= r2015b.
* mex-compatible compiler (if the included mex files do not work for your platform).
* matlab utils `global` repository ([available here](https://github.com/nfagan/global)); required for certain tests and example uses of the api.

### build instructions (common to all platforms)

```bash
git clone https://github.com/nfagan/categorical
cd ./categorical
mkdir build
cd ./build
```
#### build instructions - mac

```bash
cmake -G Xcode ..
cmake --build . --target install --config Release
```

#### build instructions - windows

```bash
cmake -G "Visual Studio 15 2017 Win64" ..
cmake --build . --target install --config Release
```

#### build instructions - linux

gcc version 4.9 is recommended for linux builds to ensure compatibility with Matlab mex files, but is not strictly neccessary.

```bash
CC=/usr/bin/gcc-4.9 CXX=/usr/bin/g++-4.9 cmake ..
cmake --build . --target install --config Release
```
