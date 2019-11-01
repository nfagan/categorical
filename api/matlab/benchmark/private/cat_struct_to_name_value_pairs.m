function nv_pairs = cat_struct_to_name_value_pairs(s)

v = struct2cell( s );
f = fieldnames( s );

nv_pairs = cell( numel(v)*2, 1 );
nv_pairs(1:2:end) = f;
nv_pairs(2:2:end) = v;

end