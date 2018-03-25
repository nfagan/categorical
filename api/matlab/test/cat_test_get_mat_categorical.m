function x = cat_test_get_mat_categorical()

this_dir = fileparts( which(mfilename) );

pathsep = '/';

if ( ispc() )
  pathsep = '\';
end

ind = max( strfind(this_dir, pathsep) );
outer_dir = this_dir(1:ind);

filepath = fullfile( outer_dir, 'data', 'categorical.mat' );

if ( exist(filepath, 'file') ~= 2 )
  error( 'Expected data to reside in a folder /data/categorical.mat' );
end

x = load( filepath );

end