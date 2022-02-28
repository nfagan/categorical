function axs = holdon(axs)

%   HOLDON -- Preserve axis content.
%
%     plots.holdon( axs ) is hold( axs, 'on' );
%
%     See also plots.panel

for i = 1:numel(axs)
  hold( axs(i), 'on' );
end

end