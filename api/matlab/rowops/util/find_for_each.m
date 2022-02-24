function I2 = find_for_each(labels, I, a)

%   FIND_FOR_EACH -- Find label(s) for each subset.
%
%     I2 = find_for_each( f, I, labels ); for the fcat object `f`,
%     cell array of index vectors `I`, and char or cell array of strings
%     `labels` calls `find( f, labels, ind )` for each element `ind` of 
%     `I` and returns a corresponding cell array of indices `I2`.
%
%     See also fcat, fcat/find

I2 = cell( size(I) );
for i = 1:numel(I)
  I2{i} = find( labels, a, I{i} );
end

end