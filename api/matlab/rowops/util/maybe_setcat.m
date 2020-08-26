function labels = maybe_setcat(labels, varargin)

%   MAYBE_SETCAT -- Assign to category, if non empty.
%
%     maybe_setcat( labels, category, value ); is the same as
%     setcat( labels, category, value ) in the case that `labels` is
%     non-empty. Otherwise, if `labels` is empty, then this function does
%     nothing.
%
%     See also fcat/setcat, maybe_addsetcat

if ( ~isempty(labels) )
  setcat( labels, varargin{:} );
end

end