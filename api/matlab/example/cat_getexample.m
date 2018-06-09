function f = cat_getexample(kind)

%   CAT_GETEXAMPLE -- Get example fcat object or data.
%
%     cat_getexample() loads and returns a small fcat object.
%     cat_getexample( 'small' ) does the same.
%     cat_getexample( 'large' ) loads and returns a large fcat object.
%     cat_getexample( 'smalldata' ) loads a small data vector.
%
%     See also fcat, cat_testall
%
%     IN:
%       - `kind` (char) |OPTIONAL|
%     OUT:
%       - `f` (fcat)

root = fcat.apiroot();

options = { 'small', 'large', 'smalldata' };

if ( nargin < 1 )
  kind = 'small';
end

switch ( kind )
  case 'large'
    f = doload( fullfile(root, 'data', 'bigfcat.mat') );
  case 'small'
    x = cat_test_get_mat_categorical();
    f = fcat.from( x.c, x.f );
  case 'smalldata'
    f = doload( fullfile(root, 'data', 'smalldata.mat') );
  otherwise
    error( 'Unrecognized data kind "%s". Options are: \n\n%s' ...
      , kind, strjoin(options, ' | ') );
end

end

function data = doload(p)
s = load( p );
fs = fieldnames( s );
data = s.(fs{1});
end