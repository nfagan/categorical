function rowops_build( p, func_name )

mex_funcs = { func_name, 'rowops.cpp', 'mex_helpers.cpp' };
mex_funcs = cellfun( @(x) fullfile(p, x), mex_funcs, 'un', false );

mex_func = strjoin( mex_funcs, ' ' );

build_cmd = sprintf( '-v COPTIMFLAGS="-O3 -fwrapv -DNDEBUG" CXXOPTIMFLAGS="-O3 -fwrapv -DNDEBUG" -outdir %s %s' ...
  , p, mex_func );

eval( sprintf('mex %s', build_cmd) );

end
