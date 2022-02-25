function build_cellstr_unique_rowi()

source_dir = fileparts( which(mfilename) );
source_p = fullfile( source_dir, 'cellstr_unique_rowi.cpp' );
cmd = sprintf( "mex -v -outdir '%s' CXXOPTIMFLAGS='$CXXOPTIMFLAGS -O3' CXX_FLAGS='$CXX_FLAGS -std=c++17' COMPFLAGS='$COMPFLAGS -Wall' '%s'" ...
  , source_dir, source_p );
eval( cmd );

end