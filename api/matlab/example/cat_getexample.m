function f = cat_getexample(kind)

%   CAT_GETEXAMPLE -- Get example fcat object.
%
%     cat_getexample() loads and returns a small fcat object.
%     cat_getexample( 'small' ) does the same.
%     cat_getexample( 'large' ) loads and returns a large fcat object.
%
%     See also fcat, cat_testall
%
%     IN:
%       - `kind` (char) |OPTIONAL|
%     OUT:
%       - `f` (fcat)

root = fcat.apiroot();

options = { 'small', 'large' };

if ( nargin < 1 )
  kind = 'small';
end

switch ( kind )
  case 'large'
    f = load( fullfile(root, 'data', 'bigfcat.mat') );
    fields = fieldnames( f );
    f = f.(fields{1});
  case 'small'
    x = cat_test_get_mat_categorical();
    f = fcat.from( x.c, x.f );
  otherwise
    error( 'Unrecognized fcat kind "%s". Options are: \n\n%s' ...
      , kind, strjoin(options, ' | ') );
end

end