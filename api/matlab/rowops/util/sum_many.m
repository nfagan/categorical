function out = sum_many(varargin)

%   SUM_MANY -- Sum of all inputs.
%
%     sum_many( a, b ) is a + b.
%     sum_many( a, b, c, ... ) is a + b + c + ...
%     sum_many( a ) is a.
%
%     See also sum

narginchk( 1, Inf );

out = varargin{1};
n = nargin;

for i = 2:n
  out = out + varargin{i};
end

end