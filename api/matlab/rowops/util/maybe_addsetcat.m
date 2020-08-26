function labels = maybe_addsetcat(labels, varargin)

%   MAYBE_ADDSETCAT -- Require category and assign to category, if non empty.
%
%     maybe_addsetcat( labels, category, value ); is the same as
%     addsetcat( labels, category, value ) in the case that `labels` is
%     non-empty. Otherwise, if `labels` is empty, then this function is a 
%     no-op.
%
%     See also fcat/addsetcat

if ( ~isempty(labels) )
  addsetcat( labels, varargin{:} );
end

end