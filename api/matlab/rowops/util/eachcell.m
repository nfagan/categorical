function varargout = eachcell(varargin)

%   EACHCELL -- cellfun with cell output.
%
%     out = eachcell( fun, array ); is the same as
%     out = cellfun( fun, array, 'uniformoutput', false );
%
%     See also cellfun

narginchk( 2, inf );
[varargout{1:nargout}] = cellfun( varargin{:}, 'UniformOutput', false );

end