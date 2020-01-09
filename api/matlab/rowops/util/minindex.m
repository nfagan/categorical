function I = minindex(X, varargin)

%   MININDEX -- Index of minima.
%
%     I = minindex( X ); is the same as [~, I] = min( X );
%     I = minindex( X, varargin ); is the same as 
%     [~, I] = min( X, varargin{:} );
%
%     See also min, maxindex

[~, I] = min( X, varargin{:} );

end