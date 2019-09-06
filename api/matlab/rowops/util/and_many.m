function out = and_many(varargin)

%   AND_MANY -- And across all inputs.
%
%     and_many( a, b ) is a & b;
%     and_many( a, b, c, ... ) is a & b & c ...
%     and_many( a ) is a.
%
%     See also or_many, sum_many

narginchk( 1, Inf );

out = logical( varargin{1} );
n = nargin;

for i = 2:n
  out = out & varargin{i};
end

end