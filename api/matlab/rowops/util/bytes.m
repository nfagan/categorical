function b = bytes(var, unit)

%   BYTES -- Get amount of reported memory usage for variable.
%
%     b = bytes( A ); returns the number of bytes A occupies, as reported
%     by Matlab.
%
%     b = bytes( A, UNIT ); where unit is one of 'b', 'kb', 'mb', or 'gb', 
%     returns the quantity in bytes, kilobytes, megabytes, or gigabytes, 
%     respectively.
%
%     See also whos, zeros, rowop

narginchk( 1, 2 );

if ( nargin < 2 )
  unit = 'b';
else
  unit = validatestring( unit, {'b', 'kb', 'mb', 'gb'}, mfilename, 'format' );
end

info = whos( 'var' );

b = info.bytes;

switch ( unit )
  case 'b'
    return
  case 'kb'
    b = b / 1024;
    return
  case 'mb'
    b = b / (1024 * 1024);
    return
  case 'gb'
    b = b / (1024 * 1024 * 1024);
    return
  otherwise
    error( 'Internal error: unimplemented unit string: "%s".', unit );
end

end