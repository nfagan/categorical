function onelegend(f, ith)

%   ONELEGEND -- Keep one legend.
%
%     ONELEGEND( f ) finds legends in the figure `f` and deletes all but
%     the first one.
%
%     ONELEGEND( f, i ); deletes all but the `i`th legend.
%
%     See also gcf

if ( nargin < 2 )
  ith = 1;
end

if ( isempty(f) )
  return
end

leg = findobj( f, 'type', 'legend' );
for i = 1:numel(leg)
  if ( i ~= ith )
    delete( leg(i) );
  end
end

end