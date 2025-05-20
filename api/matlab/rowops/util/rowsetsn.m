function [I, L] = rowsetsn(X, f, options)

%   ROWSETSN -- Partition row indices into subsets by unique row products.
%
%     I = rowsetsn( X, f ); returns indices of unique rows of the 2D array
%     `X`, evaluated over the columns `f`. `I` contains one set of indices 
%     for each unique row of `X`, evaluated over the union of columns
%     identified in `f`. `f` is a cell array whose elements index into 
%     columns of `X`.
%
%     For example, if `X` is a table, then rowsetsn( X, {["var1", "var2"} )
%     would return indices of the unique rows of X(:, ["var1", "var2"]).
%
%     `f` induces an implicit nesting structure in the order of sets in `I`.
%
%     For example, if `f` has two elements, then the unique rows of 
%       X(:, f{2})  become nested within the unique rows of 
%       X(:, f{1}), with respect to their order of appearence in `I`.
%
%     [I, L] = rowsetsn( X, f ) also returns a cell array `L` containing 
%     the unique rows of `X`, evaluated for each index set in `f`, and 
%     corresponding to `I`. Thus, `L` has one element for each element of
%     `f`, and each `L{i}` matches `I`.
%
%     [I, ...] = rowsetsn( ..., Mask=m ) computes the unique rows of 
%     `X(mask, :)`, while returning indices that are a subset of `m`. `m`
%     can be numeric or logical, but the returned indices are always
%     numeric.
%
%     A given element of `f` can be the empty array, [], in which case
%     corresponding elements of `L` will contain a missing value with the 
%     same class as `X`.
%
%     [..., L] = rowsetsn( ..., UniformOutput=tf ), when `tf` is true, 
%     returns `L` as an array of the same class as X by horizontally 
%     concatenating elements associated with each set of column indices. 
%     Default false.
%
%     //  EX 1.
%     t = struct2table( load('carbig') );
%     [I, L] = rowsetsn( t, {"Origin", "Cylinders", "when"} );
%     % plot
%     figure(1); clf; axs = plots.summarized2( t.MPG, I, L{:}, Type='bar' );
%     ylabel( axs, 'Average MPG' );
%
%     //  EX 2.
%     % plot subjects' average looking duration to different ROIs in
%     % different types of images, split by the dose of drug they received.
%     t = fcat.totable( fcat.example ); t.subject = t.monkey;
%     data = fcat.example( 'smalldata' );
%
%     % only look at a subset of image types and subjects, to make the plot 
%     % simpler
%     mask = ismember( t.image, {'outdoors', 'scrambled'} );
%     mask = mask & ismember( t.subject, {'hitch', 'ephron'} );
%
%     % group rows by subject; within subject, group by doseage and image
%     % roi; within dosage and image roi, group by the type of image.
%     [I, L] = rowsetsn( t, {"subject", ["dose", "roi"], "image"}, Mask=mask );
%
%     % plot
%     figure(1); clf; axs = plots.summarized2( data, I, L{:}, Type='error-bar' );
%     ylabel( axs(1), 'average looking duration (ms)' );
%
%     See also rowgroups, unique, grp2idx, groupi, splitapply,
%       plots.summarized3, rowsets3

arguments
  X {mustBeMatrix};
  f cell {mustBeNonempty};
  options.UniformOutput logical = false;
  options.Mask = rowmask( X );
  options.SortRows = true;
end

miss = missings( X, f );
[I, C] = dfs( X, f, options.Mask, miss );
[I, L] = fixup( X, I, C, f, miss, options );

end

function [I, C] = dfs(X, f, mask, miss)

[i, t] = rowgroups( X(:, f{1}), mask );
S = make_s( i, t, 1, [], miss );

I = {};
C = {};

while ( ~isempty(S) )
  s = S(end);
  S(end) = [];
  
  if ( s.i < numel(f) )
    [i, t] = rowgroups( X(:, f{s.i+1}), s.I );
    S = [ S; make_s(i, t, s.i+1, s.C, miss) ];
  else
    I{end+1, 1} = s.I;
    C{end+1, 1} = s.C;
  end
end

end

function [I, L] = fixup(X, I, C, f, miss, options)

if ( isempty(C) )
  % enforce that `C` has the same number of columns as elements of `f`.
  C = reshape( C, numel(I), numel(f) );
else
  C = vertcat( C{:} );
end

L = cell( 1, size(C, 2) );
for i = 1:size(C, 2)
  L{i} = vertcat( C{:, i} );
  if ( isempty(L{i}) )
    % We want elements of `L` always be selections of columns of `X`. When
    % an element of `L` is empty, we force it here to be an empty selection
    % of `X`.
    if ( isempty(miss{i}) )
      % A missing index was not specified for this col-index set, so use an
      % empty value from X.
      L{i} = X(false, f{i}); 
    else
      % A missing index *was* specified here, so use an empty missing
      % value.
      L{i} = miss{i}(false, :);
    end
  end
end

if ( options.SortRows )
  try
    [~, ord] = sortrows( horzcat(L{:}) );
    [I, L{:}] = rowref_many( ord, I, L{:} );
  catch err
    warning( err.identifier, "Failed to sort rows of `L`: %s", err.message );
  end
end

if ( options.UniformOutput )
  L = horzcat( L{:} );
end

end

function S = make_s(i, t, si, sc, miss)
if ( isempty(t) && size(t, 1) > 0 && ~isempty(miss) ), t = miss{si}; end
it = reshape( 1:size(t, 1), size(i) );
S = arrayfun( @(I, i) struct(...
  'I', I{1}, 'i', si, 'C', {[sc, {rowref(t, i)}]}), i, it );
end

function m = missings(X, f)

miss = cellfun( @isempty, f );
m = cell( size(f) );

if ( ~any(miss, 'all') )
  return
end

if ( isnumeric(X) || iscategorical(X) )
  m(miss) = { feval(class(X), nan) };
elseif ( islogical(X) )
  m(miss) = { false };
elseif ( isstring(X) )
  m(miss) = { "" };
elseif ( istable(X) )
  vn = X.Properties.VariableNames;
  vn2 = compose( "Var%d", 1:sum(miss) );
  vn2 = matlab.lang.makeUniqueStrings( vn2, string(vn) );
  m(miss) = arrayfun( @(v) table("", 'va', v), vn2, 'un', 0 );
else
  error( 'Unhandled class: "%s"', class(X) );
end

end