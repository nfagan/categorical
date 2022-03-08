function axs = cla(axs)

%   CLA -- Clear array of axes.
%
%     CLA( axs ) clears each axis in `axs`.
%
%     See also cla

for i = 1:numel(axs)
  cla( axs(i) );
end

end