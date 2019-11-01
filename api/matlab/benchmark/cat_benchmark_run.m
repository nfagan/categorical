function perf = cat_benchmark_run(func, varargin)

inputs = parse_inputs( func, varargin );

iters = inputs.iters;
ts = nan( iters, 1 );

for i = 1:iters
  ts(i) = func( i );
end

perf = struct();
perf.group = inputs.group;
perf.func = inputs.func;
perf.name = inputs.name;
perf.tags = inputs.tags;
perf.id = inputs.id;
perf.date = inputs.date;
perf.version_info = fcat.version();
perf.arch = computer( 'arch' );
perf.stats = make_stats( ts );

end

function stats = make_stats(ts)

stats = struct();
stats.mean = mean( ts );
stats.median = median( ts );
stats.min = min( ts );
stats.max = max( ts );
stats.dev = std( ts );
stats.n = numel( ts );

end

function results = parse_inputs(func, inputs)

validator = @(x, classes, attrs, name) validateattributes( x, classes, attrs, mfilename, name );
scalar_validator = @(x, classes, name) validator(x, classes, {'scalar'}, name );
char_validator = @(x, name) validator( x, {'char'}, {}, name );
cellstr_validator = @(x, name) validator( x, {'char', 'cell'}, {}, name );

func_str = func2str( func );

parser = inputParser();
parser.addParameter( 'iters', 1e3, @(x) scalar_validator(x, {'double'}, 'iters') );
parser.addParameter( 'group', func_str, @(x) char_validator(x, 'group') );
parser.addParameter( 'func', func_str, @(x) char_validator(x, 'func') );
parser.addParameter( 'name', func_str, @(x) char_validator(x, 'name') );
parser.addParameter( 'tags', {}, @(x) cellstr_validator(x, 'tags') );
parser.addParameter( 'date', datestr(now), @(x) char_validator(x, 'date') );
parser.addParameter( 'id', cat_rand_char(16), @(x) char_validator(x, 'id') );

parse( parser, inputs{:} );
results = parser.Results;
results.tags = cellstr( results.tags );

end