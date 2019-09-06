function out = union_many(varargin)

%   UNION_MANY -- Union of all inputs.
%
%     union_many( a, b ) is union( a, b );
%     union_many( a, b, c, ... ) is union( union(a, b), c );
%     union_many( a ) is a.
%
%     See also or, sum_many

narginchk( 1, Inf );

out = varargin{1};
n = nargin;

for i = 2:n
  out = union( out, varargin{i} );
end

end