function out = mean_many(varargin)

%   MEAN_MANY -- Mean of all inputs.
%
%     mean_many( a, b ) is (a + b) / 2
%     mean_many( a, b, c, ... ) is (a + b + c + ...) / N
%     mean_many( a ) is a.
%
%     See also sum

out = sum_many( varargin{:} ) / nargin;

end