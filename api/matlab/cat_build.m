function cat_build( mex_func, sub_dirs )

%   CAT_BUILD -- Build mex files.
%
%     IN:
%       - `mex_func` (char) -- Name of the .cpp file (mex function)
%       - `sub_dirs` (char, cell array of strings) |OPTIONAL| --
%         sub-directory in which `mex_func` is located, relative to where
%         `loc_build.m` is stored.

if ( nargin < 2 )
  sub_dirs = { '' };
else
  if ( ~iscell(sub_dirs) ), sub_dirs = { sub_dirs }; end
end

if ( ~iscell(mex_func) )
  mex_func = { mex_func };
end

api_dir = fileparts( which(mfilename) );

if ( ispc() )
  pathsep = '\';
else
  pathsep = '/';
end

if ( isunix() && ~ismac() )
  compiler_spec = 'GCC=''/usr/bin/gcc-4.9'' G++=''/usr/bin/g++-4.9''';
%   addtl_c_flags = ' CFLAGS="-fPIC" ';
  addtl_c_flags = '';
  addtl_cxx_flags = 'CXXFLAGS="-std=c++1y"';
else
  compiler_spec = '';
  addtl_c_flags = '';
  addtl_cxx_flags = 'CXXFLAGS="-std=c++14"';
end

api_dir_search = strjoin( {'api', 'matlab'}, pathsep );
api_dir_index = strfind( api_dir, api_dir_search );

repo_dir = api_dir(1:api_dir_index-1);

in_dir = fullfile( api_dir, sub_dirs{:} );

mex_func_paths = cellfun( @(x) fullfile(in_dir, x), mex_func, 'un', false );

cat_lib_dir = fullfile( repo_dir, 'lib' );
cat_include_dir= fullfile( repo_dir, 'include' );
cat_lib_name = 'categorical';

mex_func_path = strjoin( mex_func_paths, ' ' );

build_cmd = sprintf( '-v %s%s%s COPTIMFLAGS="-O3 -fwrapv -DNDEBUG" CXXOPTIMFLAGS="-O3 -fwrapv -DNDEBUG" %s -I%s -L%s -l%s -outdir %s' ...
  , compiler_spec, addtl_c_flags, addtl_cxx_flags, mex_func_path, cat_include_dir ...
  , cat_lib_dir, cat_lib_name, api_dir );

eval( sprintf('mex %s', build_cmd) );

end