function build_cellstr_unique_row_ic()

source_p = fullfile( fileparts(which(mfilename)), 'cellstr_unique_row_ic.cpp' );
cmd = sprintf( "mex -v CXXOPTIMFLAGS='$CXXOPTIMFLAGS -O3' CXX_FLAGS='$CXX_FLAGS -std=c++17' COMPFLAGS='$COMPFLAGS -Wall' %s" ...
  , source_p );
eval( cmd );

end