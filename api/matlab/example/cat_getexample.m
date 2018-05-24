function f = cat_getexample(kind)

%   CAT_GETEXAMPLE -- Get example fcat object.
%
%     OUT:
%       - `f` (fcat)

root = fcat.apiroot();

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
    error( 'Unrecognized fcat kind "%s".', kind );
end

end