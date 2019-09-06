function out = any_many(varargin)

%   ANY_MANY -- Any across all inputs.
%
%     any_many( a, b ) is any( a | b );
%     any_many( a, b, c, ... ) is any( a | b | c ... )
%     any_many( a ) is a.
%
%     See also any

out = any( or_many(varargin{:}) );

end