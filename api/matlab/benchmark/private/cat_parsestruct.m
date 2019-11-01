function params = cat_parsestruct(params, args)

%   CAT_PARSESTRUCT -- Assign variable inputs to struct.
%
%     params = ... parsestruct( S, ARGS ) where ARGS is a cell array of
%     'NAME', VALUE pairs assigns `VALUE1` to field `NAME1` of struct 
%     `S`, and so on for any additional number of ('name', value) pair 
%     inputs. Each 'name' must be a present fieldname of `S`.
%
%     params = ... parsestruct( S, ARGS ) where ARGS is a cell array of 
%     structs `S1`, `S2`, ... first decomposes those structs into a series 
%     of 'field', value pairs, and assigns the contents to `S` as above.
%
%     params = ... parsestruct( S, ARGS ), where `ARGS` is a cell array of
%     cell arrays `C1`, `C2`, ... recursively flattens those arrays into a 
%     single series of 'field', value pairs, and assigns the contents to 
%     `S` as above.
%
%     Note that `ARGS` can contain any valid combination of struct, cell,
%     or 'name', value paired inputs.
%
%     EX //
%
%     s = struct( 'hello', 10, 'hi', 11 );
%
%     s1 = shared_utils.general.parsestruct( s, {'hello', 11} );
%     s2 = shared_utils.general.parsestruct( s, {struct('hello', 11)} );
%     s3 = shared_utils.general.parsestruct( s, {{'hello', 11}, struct('hi', 11)} );

validateattributes( params, {'struct'}, {'scalar'}, 'parsestruct', 'params' );
validateattributes( args, {'cell'}, {}, 'parsestruct', 'args' );

try 
  args = merge_struct_cell( args );
catch err
  throw( err );
end

N = numel( args );

for i = 1:2:N
  name = args{i};
  
  if ( isfield(params, name) )
    params.(name) = args{i+1};
  else
    error( get_error_str_unrecognized_param(fieldnames(params), name) );
  end
end

end

function str = get_error_str_unrecognized_param(fields, name)

base_text = sprintf( '"%s" is not a recognized parameter name.', name );
field_text = sprintf( ' Options are:\n\n - %s', strjoin(sort(fields), '\n - ') );
str = sprintf( '%s%s', base_text, field_text );

end

function s = merge_struct_cell(args)

N = numel( args );
stp = 1;

s = {};

while ( stp <= N )
  v = args{stp};
  
  if ( ischar(v) )
    assert( stp + 1 <= N, '"name", value pairs are incomplete.' );
    
    s = [ s, args(stp), args(stp+1) ];
    stp = stp + 2;
    
  elseif ( iscell(v) )
    s = [ s, merge_struct_cell(v) ];
    stp = stp + 1;
    
  else
    assert( isstruct(args{stp}), ['Inputs must come in "name", value pairs' ...
      , ', or else be struct.'] );
    
    s = [ s, shared_utils.general.struct2varargin(v) ];
    stp = stp + 1;
  end
end


end