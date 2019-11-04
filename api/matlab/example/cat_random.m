function f = cat_random(varargin)

%   CAT_RANDOM -- Make random fcat.
%
%     f = cat_random(); creates a scalar fcat object with a category called
%     'cat1', whose single entry is a random ASCII string with 8 characters.
%
%     f = cat_random( 'name', value ); specifies additional name-value pair
%     arguments. These include:
%
%       'Rows' (numeric) -- Integer specifying the number of rows of `f`.
%       Default is 1.
%
%       'NumCategories' (numeric) -- Integer specifying the number of
%       categories of `f`. Categories are named 'cat1', 'cat2', ... 
%       Default is 1.
%
%       'NumLabelsPerCategory' (numeric) -- Integer specifying the number
%       of unique labels per category. Alternatively, a number in the range 
%       [0, 1) such that a category has NumLabelsPerCategory * Rows labels. 
%       Can also be a vector of `NumCategories` length, in which case a 
%       separate number of labels is used for each category.
%     
%       'MinLabelSize' (numeric) -- Integer giving the smallest number of
%       characters in each label. Default is 8.
%
%     See also cat_getexample, fcat

inputs = parse_inputs( varargin );

f = fcat();

add_categories( f, inputs.NumCategories );
resize( f, inputs.Rows );
add_labels_per_category( f, inputs.NumLabelsPerCategory, inputs.MinLabelSize );
prune( f );

end

function add_categories(f, num_cats)

for i = 1:num_cats
  addcat( f, sprintf('cat%d', i) );
end

end

function add_labels_per_category(f, num, label_size)

cats = getcats( f );
num_cats = numel( cats );

if ( label_size == 0 )
  return
end

for i = 1:num_cats
  if ( numel(num) > 1 )
    use_num = num( i );
  else
    use_num = num;
  end
  
  max_assign = floor( double(length(f)) / double(use_num) );
  perm_vec = randperm( length(f) );
  stp = 1;
  
  for j = 1:use_num    
    lab = rand_char( label_size );
    
    iter = 1;
    while ( haslab(f, lab) )
      lab = sprintf( '%s-%d', lab, iter );
      iter = iter + 1;
    end
    
    if ( j < use_num )
      % Pick a random subset to assign.
      num_assign = randi( max_assign, 1 );
    else
      % Fill the remaining rows.
      num_assign = length( f ) - stp + 1;
    end
    
    setcat( f, cats{i}, lab, perm_vec(stp:stp+num_assign-1) );
    stp = stp + num_assign;
  end
end

end

function c = rand_char(num)

alphabet = [ 'A':'Z', 'a':'z', '0':'9' ];
inds = randi( numel(alphabet), num, 1 );
c = alphabet(inds);

end

function results = parse_inputs(inputs)

validator = @(x, cls, attr, name) validateattributes(x, cls, attr, mfilename, name);
numeric_validator = @(x, attr, name) validator(x, {'numeric'}, attr, name );
make_numeric_validator = @(name) @(x) numeric_validator(x, {}, name );
scalar_integer_validator = @(name) @(x) numeric_validator(x, {'scalar', 'integer'}, name);

p = inputParser();
p.addParameter( 'NumCategories', 1, scalar_integer_validator('NumCategories') );
p.addParameter( 'NumLabelsPerCategory', 1, make_numeric_validator('NumLabelsPerCategory') );
p.addParameter( 'Rows', 1, scalar_integer_validator('Rows') );
p.addParameter( 'MinLabelSize', 8, scalar_integer_validator('MinLabelSize') );

p.parse( inputs{:} );
results = p.Results;

num_per_cat = results.NumLabelsPerCategory;
num_per_cat = min( num_per_cat, results.Rows );
num_num_labels = numel( num_per_cat );

if ( num_num_labels ~= 1 && num_num_labels ~= results.NumCategories )
  error( 'NumLabelsPerCategory must have a single element, or one element for each of NumCategories.' );  
end

is_non_integer = mod( num_per_cat, 1 ) ~= 0;
num_per_cat(is_non_integer) = max( floor(num_per_cat(is_non_integer) * results.Rows), 1 );

results.NumLabelsPerCategory = num_per_cat;

end