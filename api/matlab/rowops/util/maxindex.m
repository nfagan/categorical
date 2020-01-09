function I = maxindex(X, varargin)

%   MAXINDEX -- Index of maxima.
%
%     I = maxindex( X ); is the same as [~, I] = max( X );
%     I = maxindex( X, varargin ); is the same as 
%     [~, I] = max( X, varargin{:} );
%
%     See also max, minindex

[~, I] = max( X, varargin{:} );

end