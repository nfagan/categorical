function cat_build(mex_func, allow_overwrite)

%   CAT_BUILD -- Build mex files.
%
%     IN:
%       - `mex_func` (char) -- Name of the .cpp file (mex function)
%       - `allow_overwrite` (logical) -- True if existing mex-function can
%       	be overwritten. Default is false.

if ( nargin < 2 || isempty(allow_overwrite) )
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

src_dir = fullfile( api_dir, 'src' );
ver_dir = fullfile( api_dir, 'version' );

version_info = get_current_version_info( ver_dir );

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

mex_func_paths = cellfun( @(x) fullfile(src_dir, x), mex_func, 'un', false );

sources_by_func = make_file_sources( mex_func, mex_func_paths );
version_info = conditionally_make_new_build_id_file( src_dir, sources_by_func, version_info );
save_current_version_info( ver_dir, version_info, sources_by_func );

cat_lib_dir = fullfile( repo_dir, 'lib', platform_dir );
cat_include_dir= fullfile( repo_dir, 'include' );
cat_lib_name = 'categorical';

mex_func_path = strjoin( mex_func_paths, ' ' );

build_cmd = sprintf( '-v %s%s%s COPTIMFLAGS="-O3 -fwrapv -DNDEBUG" CXXOPTIMFLAGS="-O3 -fwrapv -DNDEBUG" %s -I%s -L%s -l%s -outdir %s' ...
  , compiler_spec, addtl_c_flags, addtl_cxx_flags, mex_func_path, cat_include_dir ...
  , cat_lib_dir, cat_lib_name, api_dir );

eval( sprintf('mex %s', build_cmd) );

end

function save_current_version_info(ver_dir, version_info, sources_by_func)

if ( exist(ver_dir, 'dir') ~= 7 )
  mkdir( ver_dir );
end

version_info.sources = sources_by_func;
save( fullfile(ver_dir, version_info_filename()), 'version_info' );

end

function version_info = conditionally_make_new_build_id_file(src_dir, sources_by_func, version_info)

counts_match = sources_by_func.Count == version_info.sources.Count;
keys_match = counts_match && ...
  isequal( sort(keys(version_info.sources)), sort(keys(sources_by_func)) );

need_update_file = true;

if ( keys_match )
  need_update_file = false;
  current_keys = keys( sources_by_func );
  
  for i = 1:numel(current_keys)
    curr_source = sources_by_func(current_keys{i});
    prev_source = version_info.sources(current_keys{i});
    
    if ( ~isequal(curr_source, prev_source) )
      need_update_file = true;
      break;
    end
  end
end

src_filepath = fullfile( src_dir, 'cat_version.hpp' );

if ( need_update_file || exist(src_filepath, 'file') == 0 )
  build_id = make_build_id();
  new_file_contents = make_build_id_source( build_id );
  
  fid = fopen( src_filepath, 'wt' );
  fprintf( fid, new_file_contents );
  fclose( fid );
  
  version_info.build_id = build_id;
end

end

function source = make_build_id_source(id)

source = ...
  sprintf( 'namespace util { const char* const CATEGORICAL_VERSION_ID = "%s"; }', id );

end

function build_id = make_build_id()

possible_chars = [ 'A':'Z', 'a':'z', '0':'9' ];
num_chars = numel( possible_chars );
build_id = possible_chars( randi(num_chars, 1, 32) );

end

function ver = make_version()

ver = struct();
ver.major = 0;
ver.minor = 0;
ver.patch = 0;

end

function ver_info = make_version_info()

ver_info = struct( ...
    'sources', containers.Map() ...
  , 'build_id', make_build_id() ...
  , 'version', make_version() ...
);

end

function fname = version_info_filename()

fname = 'version_info.mat';

end

function ver_info = get_current_version_info(version_dir)

version_file = fullfile( version_dir, version_info_filename() );

if ( ~exist(version_file, 'file') )
  ver_info = make_version_info();
else
  try
    ver_info = load( version_file );
    ver_info = ver_info.(char(fieldnames(ver_info)));
  catch err
    warning( err.message );
    ver_info = make_version_info();
  end
end

end

function sources_by_name = make_file_sources(func_names, func_paths)

sources = cellfun( @fileread, func_paths, 'un', 0 );
sources = cellfun( @(x) x(~isspace(x)), sources, 'un', 0 );

sources_by_name = containers.Map();

for i = 1:numel(func_names)
  sources_by_name(func_names{i}) = sources{i};
end

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