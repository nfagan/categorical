function build_cellstr_unique_row_ic()

mex -v CXXOPTIMFLAGS='$CXXOPTIMFLAGS -O3' CXX_FLAGS='$CXX_FLAGS -std=c++17' COMPFLAGS='$COMPFLAGS -Wall' cellstr_unique_row_ic.cpp

end