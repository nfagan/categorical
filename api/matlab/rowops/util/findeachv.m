function varargout = findeachv(X, varargin)

%   FINDEACHV -- Find each unique element of vector.
%
%     I = findeachv( v ); for the vector `v` returns `I`, a cell array with
%     one element for each unique element of `v`. Each element of `I` is
%     a subset of indices into `v` corresponding to a unique element of `v`.
%
%     [I, vc] = findeachv( v ); also returns `vc`, a column vector of the
%     unique elements of `v`, and corresponding to `I`.
%
%     [...] = findeachv( v, mask ); for the logical or numeric index vector
%     `mask` evaluates the subset of `v` denoted by `mask` (i.e., v(mask)),
%     and returns indices that are a subset of `mask`. The indices returned
%     by findeachv are always numeric.
%
%     See also findeach, unique, rowsets

if ( ~isa(X, 'fcat') )
  if ( isempty(X) )
    varargout{1} = {};
    if ( nargout > 1 )
      varargout{2} = emptied( X );
    end
    return
  end
  
  cls = {'numeric', 'logical', 'categorical', 'table', 'string'};
  validateattributes( X, cls, {'vector'}, mfilename, 'X' );
  
else
  if ( ncats(X) ~= 1 )
    error( 'fcat `X` must have 1 category; has %d.', ncats(X) );
    
  elseif ( isempty(X) )
    varargout{1} = {};
    if ( nargout > 1 )
      varargout{2} = copy( X );
    end
    return;
  end
end

if ( isa(X, 'table') )
  [varargout{1:nargout}] = findeach( X, 1, varargin{:} );
else
  [varargout{1:nargout}] = findeach( X(:), 1, varargin{:} );
end

end

function X = emptied(X)

if ( isa(X, 'table') )
  X = table;
else
  X = X([]);
end

end