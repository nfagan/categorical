function rowops_build( p, func_name )

if ( isunix() && ~ismac() )
  compiler_spec = 'GCC=''/usr/bin/gcc-4.9'' G++=''/usr/bin/g++-4.9'' ';
  cxx_flags = 'CXXFLAGS="-std=c++1y" ';
else
  cxx_flags = '';
  compiler_spec = '';
end

mex_funcs = { func_name, 'rowops.cpp', 'mex_helpers.cpp' };
mex_funcs = cellfun( @(x) fullfile(p, x), mex_funcs, 'un', false );

mex_func = strjoin( mex_funcs, ' ' );

build_cmd = sprintf( '-v %s%s COPTIMFLAGS="-O3 -fwrapv -DNDEBUG" CXXOPTIMFLAGS="-O3 -fwrapv -DNDEBUG" -outdir %s %s' ...
  , compiler_spec, cxx_flags, p, mex_func );

eval( sprintf('mex %s', build_cmd) );

end
