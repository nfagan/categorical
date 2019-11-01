function s = cat_datestr_ms(when)

if ( nargin < 1 )
  when = now();
end

s = datestr( when, 'mm-dd-yyyy HH.MM.SS.FFF' );

end