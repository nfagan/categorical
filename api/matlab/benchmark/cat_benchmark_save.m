function cat_benchmark_save(results, varargin)

%   CAT_BENCHMARK_SAVE -- Save benchmark results.
%
%     cat_benchmark_save( results ); saves `results` of an fcat
%     benchmarking function to disk in a directory called 'data' located
%     alongside this function, i.e., 
%     `fullfile( fcat.apiroot(), 'benchmark', 'data' )`. 
%
%     A separate file will be created for each unique group in `results`,
%     containing the subset of `results` for each group, named after the 
%     group.
%
%     If a file already exists, it will be appended-to rather than 
%     overwritten.
%
%     cat_benchmark_save( results, 'name', value ); species additional
%     name-value paired inputs. These include:
%
%       'filename' (char) -- Custom filename to use, instead of the
%       group-name. In this case, results are not separated by group, but
%       instead are all saved into `filename`.
%       'directory' (char) -- Directory in which to save, instead of the
%       default data directory. Will attempt to create it if it doesn't
%       exist.
%       'append' (logical) -- If true, an existing file will be appended-to
%       rather than overwritten.
%
%     See also cat_benchmark_load, cat_benchmark_plot, cat_benchmark_run,
%       fcat

if ( isempty(results) )
  return
end

params = parse_inputs( varargin );

if ( isempty(params.filename) )
  % Filename is not specified, so automatic / default behavior applies,
  % which is to save over or append to a different file for each unique
  % benchmark group in `results`.
  empty_filename_group_dispatch( results, params );
  return;
end

filepath = build_filepath( params );

if ( exist(params.directory, 'dir') ~= 7 )
  mkdir( params.directory );
end

[can_append, append_results] = check_load_existing_results( params, filepath );

if ( can_append )
  existing_ids = { append_results.id };
  new_ids = { results.id };
  % Only append results with new ids.
  results = [ append_results; results(~ismember(new_ids, existing_ids)) ];
end

save( filepath, 'results' );

end

function empty_filename_group_dispatch(results, params)

benchmark_groups = { results.group };
unqs = unique( benchmark_groups );

for i = 1:numel(unqs)
  params.filename = unqs{i};
  inputs = cat_struct_to_name_value_pairs( params );
  inds = strcmp( benchmark_groups, unqs{i} );
  % Recurse to save this group subset.
  cat_benchmark_save( results(inds), inputs{:} );
end

end

function [tf, results] = check_load_existing_results(params, filepath)

results = [];
tf = false;

if ( params.append && exist(filepath, 'file') == 2 )
  try
    results = load( filepath );
    results = results.(char(fieldnames(results)));
    tf = true;
  catch err
    warning( err.message );
  end
end

end

function p = build_filepath(params)

p = fullfile( params.directory, params.filename );

if ( ~endsWith(p, '.mat') )
  p = [ p, '.mat' ];
end

end

function params = parse_inputs(inputs)

validator = @(x, classes, attrs, name) validateattributes( x, classes, attrs, mfilename, name );
scalar_validator = @(x, classes, name) validator(x, classes, {'scalar'}, name);
char_validator = @(x, name) validator(x, {'char'}, {}, name );

p = inputParser();
p.addParameter( 'filename', '', @(x) char_validator(x, 'filename') );
p.addParameter( 'directory', cat_default_benchmark_data_directory(), @(x) char_validator(x, 'directory') );
p.addParameter( 'append', true, @(x) scalar_validator(x, {'logical', 'numeric'}, 'append') );

p.parse( inputs{:} );
params = p.Results;
params.append = logical( params.append );

end