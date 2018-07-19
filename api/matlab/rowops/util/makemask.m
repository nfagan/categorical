function mask = makemask(obj, varargin)

%   MAKEMASK -- Create mask vector by repeatedly applying find* functions.
%
%     mask = makemask( obj, func, labels ), where `obj` is an fcat
%     object, calls function `func` with inputs `obj` and `labels`. `func`
%     is a handle to a function that accepts up to three inputs -- the fcat 
%     object `obj`, a char or cell array of string `labels`, and a uint64 
%     mask vector -- and returns an index vector. Usually, the function 
%     will be one of `find`, `findnot`, `findor`, or `findnone`, but it 
%     need not be.
%
%     mask = makemask( obj, func1, labels1, func2, labels2, ... ) calls
%     func1 with inputs `obj` and `labels`, as above. However, `func2` is
%     then called with inputs `obj`, `labels2`, and, additionally, the
%     output of the call to `func1`. In this way, the output `mask`
%     will contain indices of rows that match an arbitrary number of 
%     criteria established by each (function, label) pair.
%
%     mask = makemask( obj, initial_mask, ... ) works as above, but calls
%     `func1` with the additional input `initial_mask`. In this way, the
%     output `mask` will contain only elements already present in
%     `initial_mask`.
%
%     EX 1 //
%
%     f = fcat.example;
%     M1 = find( f, {'face', 'saline'}, findnot(f, '0719') );
%     M2 = makemask( f, @find, {'face', 'saline'}, @findnot, '0719' );
%     isequal( M1, M2 )
%
%     EX 2: Use initial mask `M` //
%
%     f = fcat.example;
%     M = 1:100;
%     M1 = find( f, {'low', 'saline'}, findnot(f, 'outdoors', M) );
%     M2 = makemask( f, M, @find, {'low', 'saline'}, @findnot, 'outdoors' );
%     isequal( M1, M2 )
%
%     See also fcat/find, fcat/findor, fcat/findnone, fcat/findnot
%
%     IN:
%       - `varargin` (uint64, function_handle, char, cell array of strings)
%     OUT:
%       - `mask` (uint64)

N = numel( varargin );

if ( N == 0 )
  mask = reshape( 1:size(obj, 1), [], 1 );
  return;
end

begin_with_mask = false;

if ( mod(N, 2) ~= 0 )
  % check if mask input
  maybe_mask = varargin{1};
  
  if ( ~isnumeric(maybe_mask) )
    error( ['variable inputs must come in <function>, ''label'' pairs; or else begin' ...
      , ' with a numeric mask vector.'] );
  else
    mask = maybe_mask;
    varargin(1) = [];
    N = N - 1;
    begin_with_mask = true;
  end
end

for i = 1:2:N
  func = varargin{i};
  labs = varargin{i+1};
  
  if ( ~isa(func, 'function_handle') )
    error( 'Function must be function_handle; was "%s".', class(func) );
  end
  
  try
    if ( i == 1 && ~begin_with_mask )
      mask = func( obj, labs );
    else
      mask = func( obj, labs, mask );
    end
  catch err
    throw( err );
  end
end

end