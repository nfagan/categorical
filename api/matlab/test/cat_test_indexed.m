function cat_test_indexed()

f = fcat.example();
c = categorical( f );

assign_prog_match( f, c );
assign_prog_nonmatch( f, c );
assign_oob( f );


end

function assign_oob(f)

inds_from = ones( 1, 3 );
inds_to_all_zeros = zeros( 1, 3 );
inds_to_mid_zeros = [ 1, 0, 2 ];
inds_to_oob = [ 1, 2, length(f)+1 ];
inds_to_mid_oob = [ 1, length(f)+1, 2 ];

msg = 'Allowed assignment with oob indices.';

cat_test_assert_fail( @() assign(f', f, inds_to_all_zeros, inds_from), msg );
cat_test_assert_fail( @() assign(f', f, inds_to_mid_zeros, inds_from), msg );
cat_test_assert_fail( @() assign(f', f, inds_to_oob, inds_from), msg );
cat_test_assert_fail( @() assign(f', f, inds_to_mid_oob, inds_from), msg );

end

function assign_prog_nonmatch(f, c)

%   assign, non matching progenitors
f2 = copy( f );
f2(1, 1) = 'aaaa';
f2(1, 1) = f(1, 1);

assert( prune(f2') == f );
assert( ~progenitorsmatch(f2, f) );

inds_from = ones( 1, 3 );
inds_to = [ 1, 2, 3 ];
assign( f2, f, inds_to, inds_from );
c2 = c;
c2( inds_to, : ) = c(inds_from, :);
assert( isequal(categorical(f2), c2), 'Indexed assignment from/to failed.' );

end

function assign_prog_match(f, c)
%   assign, prog match
inds_from = ones( 1, 3 );
inds_to = [ 1, 2, 3 ];
f2 = assign( copy(f), f, inds_to, inds_from );
c2 = c;
c2( inds_to, : ) = c(inds_from, :);
assert( isequal(categorical(f2), c2), 'Indexed assignment from/to failed.' );
end