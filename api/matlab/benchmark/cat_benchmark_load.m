function results = cat_benchmark_load(files, varargin)

inputs = parse_inputs( files, varargin );

files = build_filepaths( inputs );

results = [];

for i = 1:numel(files)
  tmp_results = load( files{i} );
  tmp_results = tmp_results.(char(fieldnames(tmp_results)));
  
  results = [ results; tmp_results ];
end

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
char_validator = @(x, name, attrs) validator(x, {'char'}, attrs, name );

p = inputParser();
p.addRequired( 'files', @(x) validator(x, {'cell', 'char'}, {}, 'files') );
p.addParameter( 'directory', cat_default_benchmark_data_directory(), @(x) char_validator(x, 'directory') );

p.parse( files, inputs{:} );
params = p.Results;
params.files = cellstr( params.files );

end