function varargout = cat_versioninfo(varargin)

%   CAT_VERSIONINFO -- Command-line interface to categorical library 
%     version information.
%
%     version_info = cat_versioninfo() retrieves the current version
%     information. `version_info` is a struct that contains the current
%     version of the library as major, minor, and patch components; a char
%     identifier of the latest build; and a containers.Map object housing
%     the whitespace-stripped source of each file used to build the
%     cat_api mex function.
%
%     cat_versioninfo( command, arg1, arg2, ... ) modifies or queries
%     aspects of the current version info according to `command`, and
%     allows additional arguments depending on `command`.
%
%     In particular:
%       - ver_info = cat_versioninfo( 'increment' ) increments the current 
%         patch version, and returns the updated version info.
%       - ver_info = cat_versioninfo( 'set', major, minor, patch ) sets
%         each version component, and returns the updated version info. 
%         Each component must be a non-negative, non-nan integer.
%       - is_up_to_date = cat_versioninfo( 'check' ) returns true if the
%         current build-id matches the build-id of the cat_api mex file.
%       - cat_versioninfo( 'disp' ) pretty-prints the version info.
%
%     See also cat_build, fcat

api_dir = fileparts( which(mfilename) );
version_file = fullfile( api_dir, 'version', 'version_info.mat' );
version_info = load( version_file );
version_info = version_info.(char(fieldnames(version_info)));

if ( nargin > 0 )
  command = validatestring( varargin{1}, {'increment', 'set', 'check', 'disp'} ...
    , mfilename );
  
  switch ( command )
    case 'increment'
      version_info.version.patch = version_info.version.patch + 1;
      varargout = { version_info };
    case 'set'
      version_info = set_version_info( version_info, varargin(2:end) );
      varargout = { version_info };
    case 'check'
      matches = version_check( version_info );
      varargout = { matches };
    case 'disp'
      nargoutchk( 0, 0 );
      display_version_info( version_info );
  end
  
  save( version_file, 'version_info' );
else
  nargoutchk( 0, 1 );
  varargout = { version_info };
end

end

function display_version_info(version_info)

ver = version_info.version;
build_id = version_info.build_id;

fprintf( '\nMajor: %d | Minor: %d | Patch: %d | Build-id: %s\n\n' ...
  , ver.major, ver.minor, ver.patch, build_id );

end

function matches = version_check(version_info)

build_id = version_info.build_id;
current_build_id = cat_api( 'version' );

matches = isequal( build_id, current_build_id );

end

function version_info = set_version_info(version_info, remaining_args)

if ( numel(remaining_args) ~= 3 )
  error( 'Expected 3 numbers: MAJOR MINOR PATCH' );
end

for i = 1:numel(remaining_args)
  if ( ~isscalar(remaining_args{i}) )
    error( 'Version component must be scalar.' );
  end
  
  if ( ischar(remaining_args{i}) )
    ver_num = str2double( remaining_args{i} );
  else
    ver_num = remaining_args{i};
  end
  
  if ( isnan(ver_num) || mod(ver_num, 1) ~= 0 || ver_num < 0 )
    error( 'Version component must be a non-negative, non-nan integer.' );
  end
  
  switch ( i )
    case 1
      version_info.version.major = ver_num;
    case 2
      version_info.version.minor = ver_num;
    case 3
      version_info.version.patch = ver_num;
  end
end

end