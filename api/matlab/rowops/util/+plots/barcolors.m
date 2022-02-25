function hs = barcolors(hs, cs)

%   BARCOLORS -- Set colors of bars in a bar plot.
%
%     BARCOLORS( hs, cs ) for the 1xN vector of bar handles `hs` and Nx3
%     matrix of colors `cs` sets the colors of bars from the rows of `cs`.
%
%     See also plots.bars

assert( numel(hs) == size(cs, 1), 'Colors do not correspond to bar handles.' );

for i = 1:numel(hs)
  set( hs(i), 'facecolor', cs(i, :) );
end

end