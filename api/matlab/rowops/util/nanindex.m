function Y = nanindex(X, indices)

%   NANINDEX -- Index array, excluding nan indices.
%
%     IN:
%       - `X` (/T/)
%       - `indices` (double)
%     OUT:
%       - `Y` (/T/)

Y = nan( size(X) );
inds = indices( ~isnan(indices) );
Y(inds) = X(inds);

end