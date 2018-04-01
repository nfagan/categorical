function rowops_build( func_name )

mex_funcs = { func_name, 'rowops.cpp', 'mex_helpers.cpp' };

mex_func = strjoin( mex_funcs, ' ' );

build_cmd = sprintf( '-v COPTIMFLAGS="-O3 -fwrapv -DNDEBUG" CXXOPTIMFLAGS="-O3 -fwrapv -DNDEBUG" %s' ...
  , mex_func );

eval( sprintf('mex %s', build_cmd) );

end
