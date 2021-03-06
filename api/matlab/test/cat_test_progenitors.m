function cat_test_progenitors()

conf = fcat.buildconfig();
use_progenitor = conf.use_progenitor_ids;

if ( ~use_progenitor )
  return;
end

x = cat_test_get_mat_categorical();

f = fcat.from( x.c, x.f );

f2 = copy( f );

assert( progenitorsmatch(f, f2), 'Copy changed progenitor ids.' );

unique( f2 );

assert( progenitorsmatch(f, f2), 'Unique changed progenitor ids.' );

existing_lab = f2(1, 1);
f2(end, 1) = existing_lab;

assert( progenitorsmatch(f, f2), 'Inserting existing label changed progenitor ids.' );

new_lab = 'a';
assert( ~haslab(f2, new_lab), 'New label already existed.' );

keep( f2, 2 );

assert( progenitorsmatch(f, f2), 'Keeping subset changed progenitor ids.' );

f2(1, 1) = new_lab;

assert( ~progenitorsmatch(f, f2), 'Inserting new label did not change progenitor.' );

z = copy( f2 );

assert( progenitorsmatch(z, f2) );

rmcat( z, x.f{1} );

assert( ~progenitorsmatch(f2, z), 'Removing category did not change progenitor ids.' );

y = fcat.from( x.c );
z = fcat.like( y );

assert( progenitorsmatch(y, z) );

append( z, y(1:1e4) );

assert( progenitorsmatch(z, y) );

end