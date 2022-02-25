function varargout = rowref_many(I, varargin)

%   ROWREF_MANY -- Apply row index to multiple arrays.
%
%     [AP, BP] = ROWREF_MANY( I, A, B ) for matrices A and B computes 
%     AP = A(I, :) and BP = B(I, :).
%
%     [AP, BP, CP, ...] = ROWREF_MANY( I, A, B, C ... ) computes
%     AP = A(I, :), BP = B(I, :), CP = C(I, :) and so on for any number of
%     inputs. The number of output arrays must match the number of input 
%     arrays.
%
%     For any input X, all elements along dimensions (2:ndims(X)) are
%     retained. For example, if X is 3D, then XP = ROWREF_MANY( I, X ) is
%     the same as XP = X(I, :, :).
%
%     See also rowref, sum_many, union_many

assert( nargout == numel(varargin) ...
  , 'Number of outputs must match number of input index targets.' );
varargout = cell( size(varargin) );
for i = 1:numel(varargin)
  varargout{i} = rowref( varargin{i}, I );
end

end