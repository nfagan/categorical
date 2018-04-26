function cat_test_append_create()

bounds_labs = fcat.with( {'unified_filename', 'stim_type'} );

labs = fcat.like( bounds_labs );

setcat( labs, 'unified_filename', 'some other' );
setcat( labs, 'stim_type', 'stimulate' );

repmat( labs, 2 );

append( bounds_labs, labs );

% labs = fcat.like( bounds_labs );

setcat( labs, 'stim_type', 'shams' );
setcat( labs, 'unified_filename', 'some other' );

% repmat( labs, 6 );
resize( labs, 1 );

assert( ~progenitorsmatch(bounds_labs, labs) );

append( bounds_labs, labs );

new_name = 'b';

fillcat( bounds_labs, 'unified_filename', new_name );

categ = fullcat( bounds_labs, 'stim_type' );

assert( ~any(strcmp(categ, new_name)), 'Setting category a changed category b.' );

end