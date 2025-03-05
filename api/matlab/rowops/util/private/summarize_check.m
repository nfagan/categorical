function [within, vs, fs] = summarize_check(within, vs, fs)

vs = columnize( string(vs) )';
within = columnize( string(within) )';

if ( isa(fs, 'function_handle') )
  fs = repmat( {fs}, size(vs) );
else
  validateattributes( fs, {'cell'}, {'2d'}, mfilename, 'fs' );
end

end