function out = or_many(varargin)

%   OR_MANY -- Or across all inputs.
%
%     or_many( a, b ) is a | b;
%     or_many( a, b, c, ... ) is a | b | c ...
%     or_many( a ) is a.
%
%     See also or, sum_many

narginchk( 1, Inf );

out = logical( varargin{1} );
n = nargin;

for i = 2:n
  out = out | varargin{i};
end

end