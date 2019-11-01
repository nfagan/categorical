function c = cat_rand_char(num)

alphabet = [ 'A':'Z', 'a':'z', '0':'9' ];
inds = randi( numel(alphabet), num, 1 );
c = alphabet(inds);

end