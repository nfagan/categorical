function out = allcombn(varargin)

ns = zeros( size(varargin) );

for i = 1:numel(varargin)
  assert( isscalar(varargin{i}) && isa(varargin{i}, 'double') );
  ns(i) = varargin{i};
end

out = allcomb( arrayfun(@(y) arrayfun(@(x) x, 1:y, 'un', false), ns, 'un', false) );
out = cell2mat( out );

end