function p = cat_default_benchmark_data_directory()

p = fullfile( fileparts(fileparts(which(mfilename))), 'data' );

end