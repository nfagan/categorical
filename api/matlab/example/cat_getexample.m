function f = cat_getexample(kind)

%   CAT_GETEXAMPLE -- Get example fcat object or data.
%
%     cat_getexample() loads and returns a small fcat object.
%     cat_getexample( 'small' ) does the same.
%     cat_getexample( 'large' ) loads and returns a large fcat object.
%     cat_getexample( 'smalldata' ) loads and returns a small data vector.
%     cat_getexample( 'largedata' ) loads and returns a large data vector.
%
%     See also fcat, cat_testall
%
%     IN:
%       - `kind` (char) |OPTIONAL|
%     OUT:
%       - `f` (fcat)

if ( nargin < 1 )
  kind = 'small';
end

root = fullfile( fcat.apiroot(), 'data' );

options = { 'small', 'large', 'smalldata', 'largedata' };
kind = validatestring( kind, options, mfilename, 'kind' );

switch ( kind )
  case 'large'
    f = doload( fullfile(root, 'bigfcat.mat') );
  case 'small'
    x = doload( fullfile(root, 'categorical.mat') );
    f = fcat.from( x.c, x.f );
  case 'smalldata'
    f = doload( fullfile(root, 'smalldata.mat') );
  case 'largedata'
    f = doload( fullfile(root, 'largedata.mat') );
  otherwise
    error( 'Unrecognized data kind "%s". Options are: \n\n%s' ...
      , kind, strjoin(options, ' | ') );
end

end

function data = doload(p)
s = load( p );
fs = fieldnames( s );
if ( numel(fs) == 1 )
  data = s.(fs{1}); 
else
  data = s; 
end
end