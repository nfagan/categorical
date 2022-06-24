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

persistent cached_small_f;

if ( nargin < 1 )
  kind = 'small';
end

options = { 'small', 'large', 'smalldata', 'largedata', 'large2', 'largedata2' };
kind = validatestring( kind, options, mfilename, 'kind' );

root = fullfile( fcat.apiroot(), 'data' );

switch ( kind )
  case 'large'
    f = doload( fullfile(root, 'bigfcat.mat') );
  case 'large2'
    f = doload( fullfile(root, 'bigfcat2.mat') );
  case 'small'
    if ( isempty(cached_small_f) )
      x = cache_load( fullfile(root, 'categorical.mat') );
      cached_small_f = fcat.from( x.c, x.f );
    end
    f = copy( cached_small_f );    
  case 'smalldata'
    f = doload( fullfile(root, 'smalldata.mat') );
  case 'largedata'
    f = doload( fullfile(root, 'largedata.mat') );
  case 'largedata2'
    f = doload( fullfile(root, 'bigdata2.mat') );
  otherwise
    error( 'Unrecognized data kind "%s". Options are: \n\n%s' ...
      , kind, strjoin(options, ' | ') );
end

end

function data = cache_load(p)

persistent out_data;

if ( ~isempty(out_data) )
  data = out_data;
  return;
end

s = load( p );
fs = fieldnames( s );
if ( numel(fs) == 1 )
  data = s.(fs{1}); 
else
  data = s; 
end

out_data = data;

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