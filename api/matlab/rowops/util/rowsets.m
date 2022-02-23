function [I, id, C] = rowsets(n, X, varargin)

%   ROWSETS -- Indices of unique rows.
%
%     I = rowsets( 1, X, ix1 ) for the 2D array `X` and vector of column 
%     subscripts `ix1` returns a cell array of index vectors `I`.
%     Each element in `I` is a distinct subset of row indices into `X`.
%     There is one element for each unique row of `X`, evaluated using 
%     `X(:, ix1)` columns.
%
%     I = rowsets( 2, X, ix1, ix2 ) for the vectors of column subscripts
%     `ix1` and `ix2` first computes the set of unique rows over `ix1` 
%     columns, as above. Within each set, the subset of unique
%     rows over `ix2` columns is then computed. Each element of `I` is
%     still a distinct subset of row indices into `X`. There is one element
%     for each unique combination of (`ix1` x `ix2`) rows.
%
%     I = rowsets( N, X, ix1, ix2, ... ixN ) works by extension of the
%     above to compute indices of the unique combinations of
%     (`ix1` x `ix2` x ... `ixN`) rows.
%
%     [..., id] = rowsets( N, X, ... ) also returns an MxN `id` matrix
%
%     See also unique, groupi, grp2idx, fcat

validateattributes( n, {'numeric'}, {'scalar', 'integer'}, mfilename, 'n' );
validateattributes( X ...
  , {'numeric', 'fcat', 'string', 'cell', 'categorical'}, {}, mfilename, 'f' );

narginchk( 2+n, inf );

coli = varargin(1:n);
varargin = varargin(n+1:end);

defaults = struct();
defaults.mask = [];
defaults.unspecified_label = '<unspecified>';
defaults.preserve = [];
[params, provided] = shared_utils.general.parsestruct( defaults, varargin );

preserve = params.preserve;
if ( ~isempty(preserve) )
  validateattributes( preserve, {'numeric'}, {'scalar', 'integer'}, mfilename, 'preserve' );
  assert( preserve >= 1 && preserve <= n, 'Expected preserve in range [1, n].' );
end

no_mask = rowmask( X );
if ( ismember('mask', provided) )
  mask = find_if_logical( params.mask );
else
  mask = no_mask;
end

unspecified = { params.unspecified_label };

I = {};
C = cell( 0, n );
id = zeros( 0, n );
cs = {};
is = {};

sets = make_set( mask, 0, zeros(1, n) );
stp = 1;

while ( ~isempty(sets) )
  set = sets(end);
  sets(end) = [];
  assert(set.ind(set.depth+1) == 0);
  depth1 = set.depth + 1;
  ind = set.ind;
  
  if ( ~isempty(preserve) && depth1 >= preserve )
    if ( preserve == 1 )
      pi = no_mask;
    else
      pi = mask;
    end
    
    if ( is_unspecified(X, coli{depth1}) )
      cc = unspecified;
      ic = { set.mask };
    else
      [~, cc] = generalized_findall( X, coli{depth1}, pi );
      ic = generalized_find_combinations( X, coli{depth1}, cc, set.mask );
    end
  else
    [ic, cc] = generalized_findall_check_unspecified( ...
      X, coli{depth1}, set.mask, unspecified );
  end
  
  for i = 1:numel(ic)
    ind(depth1) = i;
    cs{depth1, i} = cc(:, i)';
    is(depth1, i) = ic(i);
    
    if ( depth1 == n )
      I{stp, 1} = ic{i};
      id(stp, :) = ind;
      
      for j = 1:n
        C(stp, j) = cs(j, ind(j));
      end
      
      stp = stp + 1;
    else
      sets(end+1) = make_set( ic{i}, depth1, ind );
    end
  end
end

end

function s = make_set(mask, depth, ind)
s = struct( 'mask', mask, 'depth', depth, 'ind', ind );
end

function [i, c] = generalized_findall_check_unspecified(X, coli, mask, unspecified)

if ( is_unspecified(X, coli) )
  c = unspecified;
  i = { mask };
else
  [i, c] = generalized_findall( X, coli, mask );
end


end

function I = find_combinations_eq(f, each, C, mask)

has_mask = nargin > 3;

if ( has_mask )
  tf = true( numel(mask), 1 );
else
  tf = true( size(f, 1), 1 );
end

I = cell( size(C, 2), 1 );

for i = 1:size(C, 2)
  for j = 1:size(C, 1)
    sel = C(j, i);
    if ( has_mask )
      tf = tf & f(mask, each(j)) == sel;
    else
      tf = tf & f(:, each(j)) == sel;
    end
  end
  I{i} = find( tf );
  if ( has_mask )
    I{i} = mask(I{i});
  end
  tf(:) = true;
end

end

function I = find_combinations_strcmp(f, each, C, mask)

has_mask = nargin > 3;

if ( has_mask )
  tf = true( numel(mask), 1 );
else
  tf = true( size(f, 1), 1 );
end

I = cell( size(C, 2), 1 );

for i = 1:size(C, 2)
  for j = 1:size(C, 1)
    sel = C(j, i);
    if ( has_mask )
      tf = tf & strcmp( f(mask, each(j)), sel );
    else
      tf = tf & strcmp( f(:, each(j)), sel );
    end
  end
  I{i} = find( tf );
  if ( has_mask )
    I{i} = mask(I{i});
  end
  tf(:) = true;
end

end

function I = generalized_find_combinations(f, each, C, varargin)

if ( isa(f, 'fcat') )
  I = cell( size(C, 2), 1 );
  for i = 1:size(C, 2)
    I{i} = find( f, C(:, i), varargin{:} );
  end
else
  each = find_if_logical( each );
  if ( numel(each) ~= size(C, 1) )
    error( ['Number of column identifiers (`each`) must match the number of' ...
      , ' rows of unique column combinations.'] );
  end
  
  if ( isnumeric(f) || iscategorical(f) )
    I = find_combinations_eq( f, each, C, varargin{:} );
  elseif ( iscellstr(f) || isstring(f) )
    I = find_combinations_strcmp( f, each, C, varargin{:} );
  else
    error( ...
      'Expected fcat, categorical, cellstr, or string array; got "%s".', class(f) );
  end
end

end

function [i, c] = generalized_findall(a, each, varargin)

if ( isa(a, 'fcat') )
  [i, c] = findall( a, each, varargin{:} );
else
  if ( ~ismatrix(a) )
    error( 'Expected 2D array.' );
  end
  if ( nargin < 3 )
    [c, ~, i] = unique( a(:, each), 'rows' );
    i = groupi( i );
  else
    m = varargin{1};
    [c, ~, i] = unique( a(m, each), 'rows' );
    i = cellfun( @(x) m(x), groupi(i), 'un', 0 );
  end
  c = c';
end

end

function tf = is_unspecified(f, a)

if ( isa(f, 'fcat') )
  tf = isequal( a, {} );
else
  if ( islogical(a) )
    tf = ~any( a );
  else
    tf = isempty( a );
  end
end

end

function i = find_if_logical(i)
if ( islogical(i) )
  i = find( i );
end
end