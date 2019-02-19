function cat_build(mex_func, sub_dirs, allow_overwrite)

%   CAT_BUILD -- Build mex files.
%
%     IN:
%       - `mex_func` (char) -- Name of the .cpp file (mex function)
%       - `sub_dirs` (char, cell array of strings) |OPTIONAL| --
%         sub-directory in which `mex_func` is located, relative to where
%         `loc_build.m` is stored.
%       - `allow_overwrite` (logical) -- True if existing mex-function can
%       	be overwritten. Default is false.

if ( nargin < 2 )
  sub_dirs = { '' };
else
  if ( ~iscell(sub_dirs) )
    sub_dirs = { sub_dirs }; 
  end
end

if ( nargin < 3 )
  allow_overwrite = false;
else
  validateattributes( allow_overwrite, {'logical'}, {'scalar'} ...
    , mfilename, 'allow_overwrite' );
end

if ( ~iscell(mex_func) )
  mex_func = { mex_func };
end

api_dir = fileparts( which(mfilename) );

if ( mex_function_exists(api_dir) && ~allow_overwrite )
  print_message_already_exists();
  return;
end

if ( ispc() )
  pathsep = '\';
else
  pathsep = '/';
end

if ( isunix() && ~ismac() )
  compiler_spec = 'GCC=''/usr/bin/gcc-4.9'' G++=''/usr/bin/g++-4.9'' ';
  addtl_c_flags = '';
  addtl_cxx_flags = 'CXXFLAGS="-std=c++1y -fPIC"';
else
  compiler_spec = '';
  addtl_c_flags = '';
  addtl_cxx_flags = 'CXXFLAGS="-std=c++14"';
end

api_dir_search = strjoin( {'api', 'matlab'}, pathsep );
api_dir_index = strfind( api_dir, api_dir_search );

repo_dir = api_dir(1:api_dir_index-1);
platform_dir = get_platform_directory();

in_dir = fullfile( api_dir, sub_dirs{:} );

mex_func_paths = cellfun( @(x) fullfile(in_dir, x), mex_func, 'un', false );

cat_lib_dir = fullfile( repo_dir, 'lib', platform_dir );
cat_include_dir= fullfile( repo_dir, 'include' );
cat_lib_name = 'categorical';

mex_func_path = strjoin( mex_func_paths, ' ' );

build_cmd = sprintf( '-v %s%s%s COPTIMFLAGS="-O3 -fwrapv -DNDEBUG" CXXOPTIMFLAGS="-O3 -fwrapv -DNDEBUG" %s -I%s -L%s -l%s -outdir %s' ...
  , compiler_spec, addtl_c_flags, addtl_cxx_flags, mex_func_path, cat_include_dir ...
  , cat_lib_dir, cat_lib_name, api_dir );

eval( sprintf('mex %s', build_cmd) );

end

function d = get_platform_directory()

if ( ispc() )
  d = 'win';
  return
end

if ( ismac() )
  d = 'mac';
  return
end

if ( ~isunix() )
  warning( 'Unrecognized platform: "%s".', computer );
end

d = 'linux';

end

function tf = mex_function_exists(api_dir)

func_name = 'cat_api';

is_pc = ispc();
is_unix = isunix();
is_mac = is_unix && ismac();

if ( is_pc )
  ext = 'mexw64';
elseif ( is_unix && ~is_mac )
  ext = 'mexa64';
elseif ( is_mac )
  ext = 'mexmaci64';
else
  warning( 'Unrecognized platform: "%s".', computer );
  tf = false;
  return
end

func_name = sprintf( '%s.%s', func_name, ext );
cat_api_func = fullfile( api_dir, func_name );

tf = exist( cat_api_func ) == 3;  %#ok

end

function print_message_already_exists()

fprintf( ['\n Not building because the cat_api mex function already exists\n' ...
  , ' for your platform, and allow_overwrite is false. \n Rerun with allow_overwrite = true' ...
  , ' to build.\n\n'] );

end