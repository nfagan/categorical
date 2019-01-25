function f = rand_fcat(n_categories, n_labels_per_category, n_rows, length_each_label)

%   RAND_FCAT -- Create fcat with random categories and labels.
%
%     f = rand_fcat( N_CATEGORIES, N_LABELS_PER_CATEGORY ) creates an fcat
%     object `f` with `N_CATEGORIES` randomly generated category names,
%     each with `N_LABELS_PER_CATEGORY` randomly generated labels. `f` has
%     `N_LABELS_PER_CATEGORY` rows.
%
%     f = rand_fcat( ..., N_ROWS ) specifies that `f` have `N_ROWS` rows.
%     `N_ROWS` must be an integer multiple of the number of labels per
%     category, such that each label is placed randomly in a category the
%     same number of times.
%
%     f = rand_fcat( ..., LENGTH_EACH_LABEL ) specifies that each category
%     and label name contain `LENGTH_EACH_LABEL` characters. Default is 10.
%
%     f = rand_fcat( N_CATEGORIES_AND_LABELS ) creates an
%     `N_CATEGORIES_AND_LABELS` by `N_CATEGORIES_AND_LABELS` fcat array.
%
%     f = rand_fcat() with no input arguments creates a 1x1 fcat array.
%
%     See also fcat
%
%     IN:
%       - `n_categories` (/numeric/)
%       - `n_labels_per_category` (/numeric/)
%       - `n_rows` (/numeric/)
%       - `length_each_label` (/numeric/)
%     OUT:
%       - `f` (fcat)

if ( nargin < 1 || isempty(n_categories) )
  n_categories = 1;
end

if ( nargin < 2 || isempty(n_labels_per_category) )
  if ( nargin == 1 )
    n_labels_per_category = n_categories;
  else
    n_labels_per_category = 1;
  end
end

if ( nargin < 3 || isempty(n_rows) )
  n_rows = n_labels_per_category;
end

if ( nargin < 4 || isempty(length_each_label) )
  length_each_label = 10;
end

attrs = { 'scalar', 'positive', 'integer' };
classes = { 'numeric' };
description = mfilename;

validateattributes( n_categories, classes, attrs, description, 'n_categories' );
validateattributes( n_labels_per_category, classes, attrs, description, 'n_labels_per_category' );
validateattributes( n_rows, classes, attrs, description, 'n_rows' );
validateattributes( length_each_label, classes, attrs, description, 'length_each_label' );

assert( n_rows >= n_labels_per_category, ['Number of rows must be greater than or equal to' ...
  , ' the number of labels in each category.'] );
assert( mod(n_rows, n_labels_per_category) == 0, ['Number of labels in each' ...
  , ' category must be an integer factor of the number of rows.'] );

row_factor = n_rows / n_labels_per_category;

f = fcat();

for i = 1:n_categories
  category = add_unique_category( f, length_each_label );
  
  if ( i == 1 ), resize( f, n_rows ); end
  
  inds = 1:n_rows;
  
  for j = 1:n_labels_per_category
    use_inds = inds( randperm(numel(inds), row_factor) );
    
    add_unique_label( f, category, length_each_label, use_inds );    
    
    inds = setdiff( inds, use_inds );
  end
end

prune( f );

end

function lab = add_unique_label(f, category, length_each_label, indices)

lab = randstr( length_each_label );

while ( haslab(f, lab) )
  lab = randstr( length_each_label );
end

setcat( f, category, lab, indices );

end

function category = add_unique_category(f, length_each_label)

category = randstr( length_each_label );
  
while ( hascat(f, category) )
  category = randstr( length_each_label );
end

addcat( f, category );

end

function s = randstr(n_characters)

persistent alphabet;
persistent N;

if ( isempty(alphabet) )
  alphabet = char( 97:122 );
  N = numel( alphabet );
end

s = alphabet( randi(N, 1, n_characters) );

end