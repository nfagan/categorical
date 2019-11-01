function results = cat_benchmark_config(varargin)

make_empty = false;

if ( nargin == 1 )
  if ( isstruct(varargin{1}) )
    varargin = cat_struct_to_name_value_pairs( varargin{1} );
  elseif ( isequal(varargin{1}, []) )
    varargin = {};
    make_empty = true;
  end
end

validator = @(x, classes, attrs, name) validateattributes( x, classes, attrs, mfilename, name );
scalar_validator = @(x, classes, name) validator(x, classes, {'scalar'}, name );
cellstr_validator = @(x, name) validator( x, {'char', 'cell'}, {}, name );

parser = inputParser();
parser.addParameter( 'iters', 1e3, @(x) iters_validator(x, mfilename) );
parser.addParameter( 'tags', {}, @(x) cellstr_validator(x, 'tags') );

parse( parser, varargin{:} );
results = parser.Results;
results.tags = cellstr( results.tags );

if ( make_empty )
  results = results([]);
end

end

function iters_validator(iters, filename)

validateattributes( iters, {'double'}, {'scalar'}, mfilename, 'iters' );

end