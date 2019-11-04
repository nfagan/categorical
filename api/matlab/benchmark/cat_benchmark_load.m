function results = cat_benchmark_load(files, varargin)

%   CAT_BENCHMARK_LOAD -- Load benchmark results.
%
%     results = cat_benchmark_load( filename ); loads benchmarking results
%     stored in `filename`, a file located in the benchmarking data
%     directory, i.e., `fullfile( fcat.apiroot(), 'benchmark', 'data' )`.
%
%     results = cat_benchmark_load( filenames ); for the cell array of
%     strings `filenames`, loads results from each of `filenames`.
%
%     results = cat_benchmark_load( ..., 'name', value ); species 
%     additional name-value paired inputs. These include:
%
%       'directory' (char) -- Looks for `files` in `directory`, instead of
%       the default benchmark data directory.
%
%     See also cat_benchmark_save, cat_benchmark_plot, fcat

inputs = parse_inputs( files, varargin );

files = build_filepaths( inputs );

results = cell( numel(files), 1 );

for i = 1:numel(files)
  tmp_results = load( files{i} );
  results{i} = tmp_results.(char(fieldnames(tmp_results)));
end

results = vertcat( results{:} );

end

function files = build_filepaths(inputs)

files = unique( cellfun(@(x) fullfile(inputs.directory, x), inputs.files, 'un', 0) );

for i = 1:numel(files)
  if ( ~endsWith(files{i}, '.mat') )
    files{i} = [ files{i}, '.mat' ];
  end
end

end

function params = parse_inputs(files, inputs)

validator = @(x, classes, attrs, name) validateattributes( x, classes, attrs, mfilename, name );
char_validator = @(x, name) validator(x, {'char'}, {}, name );

p = inputParser();
p.addRequired( 'files', @(x) validator(x, {'cell', 'char'}, {}, 'files') );
p.addParameter( 'directory', cat_default_benchmark_data_directory(), @(x) char_validator(x, 'directory') );

p.parse( files, inputs{:} );
params = p.Results;
params.files = cellstr( params.files );

end