classdef fcat < handle
  
  properties (Access = private, Constant = true)
    DISPLAY_MODES = { 'auto', 'short', 'full' };
    MAX_ROWS_DISPLAY_FULL = 1000;
  end
    
  properties (Access = private)
    id;
    displaymode;
  end
  
  methods
    
    function obj = fcat(id)
      
      %   FCAT -- Create fcat object.
      %
      %     FCAT objects are meant to group and identify subsets of data, 
      %     in the vein of categorical arrays.
      %
      %     FCAT objects are essentially categorical matrices whose
      %     elements are unique across, but not necessarily within,
      %     columns. In this way, each column of an FCAT object constitutes 
      %     a category (or dimension) with an arbitrary number of levels 
      %     (or labels). Rows of observations can then be identified by a 
      %     given combination of labels across all categories.
      %
      %     See also fcat/findall, fcat/from, fcat/subsref, categorical/categorical
      
      if ( nargin == 0 )
        obj.id = cat_api( 'create' );
      else
        try
          fcat.validate_constructor_signature( dbstack() );
        catch err
          throwAsCaller( err );
        end
        obj.id = id;
      end
      %   set default display mode
      obj.displaymode = 'auto';
    end
    
    function tf = eq(obj, B)
      
      %   EQ -- True if two fcat objects have equal contents.
      %
      %     See also fcat/ne, fcat/findall
      %
      %     IN:
      %       - `B` (/any/)
      %     OUT:
      %       - `tf` (logical)
      
      if ( ~isa(obj, 'fcat') || ~isa(B, 'fcat') )
        tf = false;
        return;
      end
      
      tf = cat_api( 'equals', obj.id, B.id );      
    end
    
    function tf = ne(obj, B)
      
      %   NE -- True if objects are not fcat objects with equal contents.
      %
      %     See also fcat/eq
      %
      %     IN:
      %       - `B` (/any/)
      %     OUT:
      %       - `tf` (logical)
      
      tf = ~eq( obj, B );
    end
    
    function n = numel(varargin)
      
      %   SIZE -- Get the number of elements in the object.
      %
      %     See also fcat/size
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = prod( size(varargin{1}) );
    end
    
    function tf = isempty(obj)
      
      %   ISEMPTY -- True if the object is of size 0.
      %
      %     See also fcat/numel
      %
      %     OUT:
      %       - `tf` (logical)
      
      tf = numel( obj ) == 0;      
    end
    
    function sz = size(obj, dim)
      
      %   SIZE -- Get the number of rows in the object.
      %
      %     See also fcat/numel, fcat/getlabs
      %
      %     IN:
      %       - `dimension` |OPTIONAL| (numeric)
      %     OUT:
      %       - `sz` (uint64)
      
      if ( nargin == 1 )
        if ( isvalid(obj) )
          sz = [ cat_api('size', obj.id), ncats(obj) ];
        else
          sz = uint64( [0, 0] );
        end
        return;
      end
      
      msg = [ 'Dimension argument must be a positive integer' ...
          , ' scalar within indexing range.' ];
        
      if ( ~isnumeric(dim) || ~isscalar(dim) || dim < 1 )
        error( msg );
      end
      
      if ( dim > 2 )
        if ( isvalid(obj) )
          sz = 1;
        else
          sz = 0;
        end
        return;
      end
      
      if ( dim == 2 )
        if ( isvalid(obj) )
          sz = ncats( obj );
        else
          sz = 0;
        end
        return;
      end
      
      if ( isvalid(obj) )
        sz = cat_api( 'size', obj.id );
      else
        sz = 0;
      end
    end
    
    function s = end(obj, ind, N)
      
      %   END -- Get the final index in a given dimension.
      %
      %     IN:
      %       - `ind` (double)
      %       - `N` (double)
      %     OUT:
      %       - `s` (double)
      
      s = size( obj, ind );
    end
    
    function n = nlabs(obj)
      
      %   NLABS -- Get the current number of labels.
      %
      %     See also fcat/size, fcat/ncats, fcat/numel
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = cat_api( 'n_labs', obj.id );      
    end
    
    function n = ncats(obj)
      
      %   NCATS -- Get the current number of categories.
      %
      %     See also fcat/size, fcat/labs, fcat/numel
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = cat_api( 'n_cats', obj.id );      
    end
    
    function c = count(obj, labels)
      
      %   COUNT -- Count the number of rows associated with labels.
      %
      %     IN:
      %       - `labels` (char, cell array of strings)
      %     OUT:
      %       - `c` (uint64)
      
      c = cat_api( 'count', obj.id, labels );            
    end
    
    function obj = resize(obj, to)
      
      %   RESIZE -- Expand or contract object.
      %
      %     See also fcat/size
      %
      %     IN:
      %       - `to` (uint64)
      
      cat_api( 'resize', obj.id, uint64(to) );      
    end
    
    function obj = repeat(obj, n_times)
      
      %   REPEAT -- Repeat entire contents N times.
      %
      %     See also fcat/resize, repmat
      
      cat_api( 'repeat', obj.id, uint64(n_times) );      
    end
    
    function obj = subsasgn(obj, s, values)
      
      %   SUBSASGN -- Subscript assignment.
      %
      %     obj('category') = 'label'; sets the full contents of 'category'
      %     to 'label'.
      %
      %     obj(1:10, 'category') = 'label'; sets the first 10 elements,
      %     only.
      %
      %     obj(2:3, 'category') = { 'lab1', 'lab2' } sets the second and
      %     third elements to 'lab1' and 'lab2', respectively.
      %
      %     obj(1, 1) = 'label' assigns 'label' to the first row of the
      %     first category. The order of categories is consistent with the 
      %     output of `getcats`.
      %
      %     See also fcat/subsref, fcat/fcat, fcat/getcats
      %
      %     IN:
      %       - `s` (struct)
      %       - `values` (/any/)
      
      try
        switch ( s(1).type )
          case '()'
            assert( numel(s) == 1, ...
              'Nested assignments with "()" are illegal.' );
            
            subs = s(1).subs;
            
            if ( numel(subs) == 1 )
              
              sub = subs{1};
              is_colon = strcmp( sub, ':' );
              
              if ( isnumeric(sub) || is_colon )
                if ( isa(values, 'double') && isempty(values) )
                  %
                  % x(1:10) = [];
                  %
                  if ( is_colon )
                    keep( obj, [] );
                  else
                    inds = true( size(obj, 1), 1 );
                    assert( all(sub > 0 & sub <= size(obj, 1)), ...
                      'Index exceeds categorical dimensions.' );
                    inds(sub) = false;
                    keep( obj, find(inds) );
                  end
                else
                  %
                  % x(1:10) = other_fcat; | x(:) = other_fcat;
                  %
                  if ( is_colon )
                    assign( obj, values, 1:size(obj, 1) );
                  else
                    assign( obj, values, sub );
                  end
                end
              else
                %
                % x('hi') = 'sup';
                %
                setcat( obj, sub, values );
              end
            elseif ( numel(subs) == 2 )
              is_colon_m = strcmp( subs{1}, ':' );
              is_colon_n = strcmp( subs{2}, ':' );
              
              if ( is_colon_m )
                if ( is_colon_n )
                  %
                  % x(:, :) = values
                  %
                  setcats( obj, getcats(obj), values );
                elseif ( ischar(subs{2}) )
                  %
                  % x(:, 'hi') = 'sup';
                  % 
                  setcat( obj, subs{2}, values );
                else
                  %
                  % x(:, 1) = 'val'
                  %
                  nums = subs{2};
                  cats = getcats( obj );
                  msg = 'Category index must be numeric or a colon.';
                  if ( ~is_colon_n )
                    assert( isnumeric(nums), msg );
                    c = cats(nums);
                  else
                    c = cats;
                  end
                  setcats( obj, c, values );
                end
              else  %  not colon m
                if ( ischar(subs{2}) && ~is_colon_n )
                  %
                  % x(1:10, 'hi') = 'sup';
                  % 
                  setcat( obj, subs{2}, values, subs{1} );
                else
                  %
                  % x(1:2, 1) = 'sup' | x(1:2, 2:4) = { .. } | 
                  % x(1:2, :) = 'hi'
                  %
                  nums = subs{2};
                  msg = 'Category index must be numeric or a colon.';
                  if ( ~is_colon_n )
                    assert( isnumeric(nums), msg );
                    cats = getcats( obj );
                    c = cats(nums);
                  else
                    c = getcats( obj );
                  end
                  %
                  % do the assignment
                  %
                  setcats( obj, c, values, subs{1} );
                end
              end
            else
              error( 'Too many or too few subscripts.' );
            end
          otherwise
            error( 'Assignment with "%s" is not supported.', s(1).type );
        end
      catch err
        throwAsCaller( err );
      end
    end
    
    function varargout = subsref(obj, s)
      
      %   SUBSREF -- Subscript reference.
      %
      %     [I, C] = obj.findall( 'category' ); calls the method 'findall'
      %     with inputs 'category'.
      %
      %     c = obj('category') returns the unique labels in category 
      %     'category', if it exists, or else throws an error.
      %
      %     c = obj(1:10, 'category') returns the first 10 labels in
      %     'category', in order, throwing an error if size is less than
      %     10.
      %
      %     c = obj([1; 1; 1], 'category') works as above, but returns a
      %     3x1 array of the duplicated first label in 'category'.
      %
      %     c = obj(:, 'category') returns the full 'category'.
      %
      %     c = obj(1, 1) returns the first element in the first category
      %     of `obj`. The order of categories is consistent with the output
      %     of `getcats()`.
      %
      %     c = obj(:, 1) returns the first full category of `obj`.
      %
      %     c = obj(1:10) returns a copied fcat object whose elements are
      %     the first 10 rows of `obj`.
      %
      %     c = obj(:) creates a copy of `obj`.
      %
      %     See also fcat/subsasgn, fcat/fcat, fcat/getcats
      %
      %     IN:
      %       - `s` (struct)
      %     OUT:
      %       - `varargout` (cell)
      
      subs = s(1).subs;
      type = s(1).type;
      n_subs = numel( subs );

      s(1) = [];
      
      try
        switch ( type )
          case '()'
            assert( n_subs > 0, 'Invalid function-like invocation of a variable.' );

            category_or_inds = subs{1};

            if ( n_subs == 1 )
              if ( isnumeric(category_or_inds) )
                %
                % c = obj(1:10);
                %
                varargout{1} = keep( copy(obj), category_or_inds );
              else
                if ( strcmp(category_or_inds, ':') )
                  %
                  % c = obj(:);
                  %
                  varargout{1} = copy( obj );
                else
                  %
                  % c = obj('category');
                  %
                  varargout{1} = incat( obj, category_or_inds );
                end                
              end
            else
              assert( n_subs == 2, 'Too many subscripts.' );

              index_or_colon = subs{2};
              is_colon_cat = strcmp( category_or_inds, ':' );
              is_colon_idx = strcmp( index_or_colon, ':' );
              
              if ( isnumeric(category_or_inds) || is_colon_cat )
                %
                % obj(1, 'test1') | obj(:, 'test1')
                %
                if ( ~is_colon_idx && ischar(index_or_colon) )
                  if ( is_colon_cat )
                    varargout{1} = fullcat( obj, index_or_colon );
                    return;
                  else
                    varargout{1} = partcat( obj, index_or_colon, category_or_inds );
                    return;
                  end
                end
                %
                % obj(1, 1) | obj(1, :) | obj(:, 1) | obj(:, :)
                %
                cats = getcats( obj );
                
                if ( ~strcmp(index_or_colon, ':') )
                  cats = cats(index_or_colon);
                end
                
                all_rows = strcmp( category_or_inds, ':' );
                
                if ( all_rows )
                  out = fullcat( obj, cats );
                else
                  out = partcat( obj, cats, category_or_inds );
                end
                
                varargout{1} = out;
                return;
              end
              
              if ( ischar(category_or_inds) )
                error( 'Category must be column, not row, subscript.' );
              end
              
              error( 'Invalid reference signature.' );
            end
          case '.'
            if ( any(strcmp(methods(obj), subs)) )
              func = eval( sprintf('@%s', subs) );
              %   if the ref is to a method, but is called without ()
              if ( numel(s) == 0 )
                s(1).subs = {};
              end
              inputs = [ {obj} {s(:).subs{:}} ];
              [varargout{1:nargout()}] = func( inputs{:} );
              return;
            end
          otherwise
            error( 'Referencing with "%s" is not supported.', type );
        end
      catch err
        throwAsCaller( err );
      end
    end
    
    function obj = only(obj, labels)
      
      %   ONLY -- Retain rows associated with labels.
      %
      %     See also fcat/keep, fcat/find
      
      keep( obj, find(obj, labels) );
    end
    
    function obj = keep(obj, indices)
      
      %   KEEP -- Retain rows at indices.
      %
      %     See also fcat/fcat, fcat/findall
      %
      %     IN:
      %       - `indices` (uint64)
      
      cat_api( 'keep', obj.id, uint64(indices) );     
    end
    
    function [obj, I, C] = keepeach(obj, categories)
      
      %   KEEPEACH -- Retain one row for each combination of labels.
      %
      %     See also fcat/findall
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %     OUT:
      %       - `obj` (fcat) -- Modified object.
      %       - `I` (cell array of uint64)
      %       - `C` (cell array of strings)
      
      if ( nargout > 2 )
        [I, C] = cat_api( 'keep_eachc', obj.id, categories );
        
        if ( ~ischar(categories) )
          C = reshape( C, numel(categories), numel(C) / numel(categories) );
        end
      else
        I = cat_api( 'keep_each', obj.id, categories );
      end
    end
    
    function C = unique(obj, categories, flag)
      
      %   UNIQUE -- Get unique combinations of labels in categories.
      %
      %     C = unique( obj ) returns an MxN cell array of M unique rows of
      %     labels in N categories.
      %
      %     C = unique( obj, [] ) does the same.
      %
      %     C = unique( obj, 'cat1' ) returns an Mx1 cell array of the
      %     unique labels in 'cat1'.
      %
      %     C = unique( obj, {'cat1', 'cat2'} ) returns an Mx2 cell array
      %     of the unique rows of labels in 'cat1' and 'cat2'.
      %
      %     Rows are not sorted, but instead appear in the order in which
      %     they appear in the full array.
      %
      %     C = unique( ..., 'sorted' ) sorts the rows of `C`, in which
      %     case the output of `unique` is equivalent to the behavior of
      %     Matlab's categorical/unique function with the 'rows' specifier.
      %
      %     See also fcat/combs, categorical/unique
      
      if ( nargin == 1 || isempty(categories) )
        categories = getcats( obj );
      end
      
      C = combs( obj, categories )';
      
      if ( nargin == 3 )
        if ( strcmp(flag, 'sorted') )
          C = cellstr( unique(categorical(C), 'rows') );
        else
          valid_flags = { 'sorted' };
          error( 'Invalid flag. Flag can be "%s".', strjoin(valid_flags, ' | ') );
        end
      end
    end
    
    function C = combs(obj, categories)
      
      %   COMBS -- Get present combinations of labels in categories.
      %
      %     C = combs( obj ) returns an MxN cell array of N label
      %     combination in M categories.
      %
      %     C = combs( obj, 'cat1' ) returns the unique labels in 'cat1'.
      %
      %     C = combs( obj, {'cat1', 'cat2'} ) returns a 2xN cell array of
      %     N label combinations in categories 'cat1' and 'cat2'.
      %
      %     See also fcat/findall
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %     OUT:
      %       - `cmbs` (uint32)
      
      if ( nargin == 1 )
        categories = getcats( obj );
      end
      
      [~, C] = findall( obj, categories );
    end
    
    function [I, C] = findall(obj, categories)
      
      %   FINDALL -- Get indices of combinations of labels in categories.
      %
      %     I = findall( obj, ['test1', 'test2'] ) returns a cell array of
      %     uint64 indices `I`, where each index in I identifies a unique
      %     combination of labels in categories 'test1' and 'test2'
      %
      %     I = findall( obj ) finds all possible combinations of labels in
      %     all categories.
      %
      %     [I, C] = ... also returns `C`, an MxN matrix of M categories by
      %     N combinations, where each column `i` of C identifies the
      %     labels used to generate the i-th index of I.
      %
      %     See also fcat/combs, fcat/find
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %     OUT:
      %       - `I` (cell array of uint64)
      %       - `C` (cell array of strings)
      
      if ( nargin < 2 )
        categories = getcats( obj );
      end
      
      if ( nargout > 1 )
        [I, C] = cat_api( 'find_allc', obj.id, categories );
        if ( ~ischar(categories) )
          C = reshape( C, numel(categories), numel(C) / numel(categories) );
        else
          C = C(:)';
        end
      else
        I = cat_api( 'find_all', obj.id, categories );
      end
    end
    
    function I = find(obj, labels)
      
      %   FIND -- Get indices associated with labels.
      %
      %     Within a category, indices are calculated via an `or` operation.
      %     Across categories, indices are calculated via an `and` operation.
      %
      %     E.g., if `obj` is a fcat with labels '0' and '1' in 
      %     category '0', then find( obj, {'0', '1'} ) returns rows 
      %     associated with '0' OR '1'.
      %
      %     But if `obj` is a fcat with labels '0' and '1' in 
      %     categories '0' and '1', respectively, then 
      %     find( obj, {'0', '1'} ) returns the subset of rows associated 
      %     with '0' AND '1'.
      %
      %     See also fcat/getlabs, fcat/getcats
      %
      %     IN:
      %       - `labels` (uint32)
      %     OUT:
      %       - `inds` (uint32)
      
      I = cat_api( 'find', obj.id, labels );
    end
    
    function C = getcats(obj)
     
      %   GETCATS -- Get category names.
      %
      %     See also fcat/getlabs, fcat/fcat
      %
      %     OUT:
      %       - `C` (cell array of strings)
      
      C = cat_api( 'get_cats', obj.id );      
    end
    
    function L = getlabs(obj)
      
      %   GETLABS -- Get label names.
      %
      %     See also fcat/getcats
      %
      %     OUT:
      %       - `L` (cell array of strings)
      
      L = cat_api( 'get_labs', obj.id );      
    end
    
    function id = getid(obj)
      
      %   GETID -- Get unique instance id.
      %
      %     OUT:
      %       - `id` (uint64)
      
      id = obj.id;
    end
    
    function tf = haslab(obj, labels)
      
      %   HASLAB -- True if the label(s) exists.
      %
      %     IN:
      %       - `labels` (char, cell array of strings)
      %     OUT:
      %       - `tf` (logical)
      
      tf = cat_api( 'has_lab', obj.id, labels );      
    end
    
    function tf = hascat(obj, categories)
      
      %   HASLAB -- True if the category(ies) exists.
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %     OUT:
      %       - `tf` (logical)
      
      tf = cat_api( 'has_cat', obj.id, categories );      
    end
    
    function C = fullcat(obj, categories)
      
      %   FULLCAT -- Get complete category or categories.
      %
      %     See also fcat/setcat
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %     OUT:
      %       - `C` (cell array of strings)
      
      C = cat_api( 'full_cat', obj.id, categories );
      
      if ( ~ischar(categories) && numel(categories) > 1 )
        C = reshape( C, numel(C) / numel(categories), numel(categories) );
      end
    end
    
    function C = partcat(obj, categories, indices)
      
      %   PARTCAT -- Get part of a category or categories.
      %
      %     IN:
      %       - `categories` (char)
      %       - `indices` (uint64)
      
      C = cat_api( 'partial_cat', obj.id, categories, uint64(indices) );
      
      if ( ~ischar(categories) && numel(categories) > 1 )
        C = reshape( C, numel(C) / numel(categories), numel(categories) );
      end
    end
    
    function C = incat(obj, category)
      
      %   INCAT -- Get labels in category.
      %
      %     See also fcat/fullcat
      %
      %     IN:
      %       - `category` (char)
      %     OUT:
      %       - `C` (cell array of strings)
      
      C = cat_api( 'in_cat', obj.id, category );
    end
    
    function obj = requirecat(obj, category)
      
      %   REQUIRECAT -- Add category if it does not exist.
      %
      %     See also fcat/findall
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'require_cat', obj.id, category );
    end
    
    function obj = rmcat(obj, category)
      
      %   RMCAT -- Remove category(ies).
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'rm_cat', obj.id, category );        
    end
    
    function obj = collapsecat(obj, category)
      
      %   COLLAPSECAT -- Collapse category to single label.
      %
      %     collapsecat( obj, 'test1' ) replaces all labels in the category
      %     'test1' with the collapsed expression for that category, if
      %     there is more than one label in the category.
      %
      %     collapsecat( obj, {'test1', 'test2'} ) works as above, but for
      %     multiple categories at once.
      %
      %     See also fcat/requirecat
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'collapse_cat', obj.id, category );
    end
    
    function obj = one(obj)
      
      %   ONE -- Collapse all categories, and retain a single row.
      
      cat_api( 'one', obj.id );
    end
    
    function obj = setcat(obj, category, to, at_indices)
      
      %   SETCATEGORY -- Assign labels to category.
      %
      %     A) setcat( obj, 'hi', {'hello', 'hello', 'hello'} ) assigns
      %     {'hello', 'hello', 'hello'} to category 'hi'.
      %
      %     If the object was empty beforehand, it will become of size 3x1,
      %     and additional categories will be filled with the collapsed
      %     expression for each category. Otherwise, the object must be of 
      %     size 3x1.
      %
      %     B) setcat( obj, 'hi', {'hello', 'hello'}, [1, 2] ) assigns
      %     {'hello', 'hello'} to rows [1, 2] of the object. If the object
      %     was empty beforehand, assignment proceeds as above. Otherwise,
      %     only rows [1, 2] will be modified, and it is an error if the
      %     largest row exceeds the object's size, or if the number of rows
      %     does not equal the number of assigned labels.
      %
      %     C) setcat( obj, 'hi', 'hello', 1:10 ) works as in B), except
      %     that the single label 'hello' is implicitly expanded to a 10x1
      %     cell array of {'hello'}.
      %
      %     D) setcat( obj, 'hi', 'hello' ) works as in A) if the object
      %     was empty beforehand, implicitly transforming 'hello' into a 
      %     1x1 cell array. Otherwise, the full contents of the category 
      %     'hi' are set to 'hello'.
      %
      %     See also fcat/requirecat, fcat/fillcat
      %
      %     IN:
      %       - `category` (char)
      %       - `to` (cell array of strings)
      
      if ( nargin == 3 )
        cat_api( 'set_cat', obj.id, category, to );
      else
        cat_api( 'set_partial_cat', obj.id, category, to, uint64(at_indices) );
      end
    end
    
    function obj = setcats(obj, categories, to, at_indices)
      
      %   SETCATS -- Assign values to categories.
      %
      %     See also fcat/subsref, fcat/setcat
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %       - `to` (cell array of strings)
      
      if ( nargin == 3 )
        cat_api( 'set_cats', obj.id, categories, to );
      else
        cat_api( 'set_partial_cats', obj.id, categories, to, uint64(at_indices) );
      end  
    end
    
    function obj = fillcat(obj, cat, lab)
      
      %   FILLCAT -- Set entire contents of category to label.
      %
      %     See also fcat/setcat
      %
      %     IN:
      %       - `cat` (char)
      %       - `lab` (char)
      
      cat_api( 'fill_cat', obj.id, cat, lab );      
    end
    
    function [obj, n] = prune(obj)
      
      %   PRUNE -- Remove labels without rows.
      %
      %     prune( obj ) ensures that each label in `obj` is associated
      %     with at least one row.
      %
      %     [obj, n] = prune( obj ) also returns the number of labels that
      %     were removed.
      %
      %     See also categorical/removecats
      %
      %     OUT:
      %       - `obj` (fcat)
      %       - `n` (uint64)
      
      n = cat_api( 'prune', obj.id );
    end
    
    function obj = append(obj, B)
      
      %   APPEND -- Append another fcat object.
      %
      %     See also fcat/fcat
      %
      %     IN:
      %       - `B` (fcat)
      
      if ( ~isa(obj, 'fcat') )
        error( 'Cannot append objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'fcat') )
        error( 'Cannot append objects of class "%s".', class(B) );
      end
      
      cat_api( 'append', obj.id, B.id );
    end
    
    function obj = vertcat(obj, varargin)
      
      %   VERTCAT -- Append other fcat objects.
      %
      %     See also fcat/append
      %
      %     IN:
      %       - `B` (fcat)
      
      for i = 1:numel(varargin)
        append( obj, varargin{i} );
      end
    end
    
    function obj = assign(obj, B, to_indices, from_indices)
      
      %   ASSIGN -- Assign contents of other fcat at indices.
      %
      %     assign( obj, B, 1:10 ) assigns the full contents of `B` to rows
      %     1:10 of `obj`. `B` must have 10 rows.
      %
      %     assign( obj, B, 1:10, 11:20 ) assigns rows 11:20 of `B` to rows
      %     1:10 of `obj`.
      %
      %     IN:
      %       - `B` (fcat)
      %       - `to_indices` (uint64)
      %       - `from_indices` (uint64)
      
      if ( ~isa(obj, 'fcat') )
        error( 'Cannot assign objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'fcat') )
        error( 'Cannot assign objects of class "%s".', class(B) );
      end
      
      if ( nargin == 3 )
        cat_api( 'assign', obj.id, B.id, uint64(to_indices) );
      else
        cat_api( 'assign_partial', obj.id, B.id ...
          , uint64(to_indices), uint64(from_indices) );
      end
    end
    
    function delete(obj)
      
      %   DELETE -- Delete object and free memory.
      %
      %     See also fcat/fcat
      %
      %     Calling `clear obj` also deletes the object.
      
      cat_api( 'destroy', obj.id );
    end
    
    function B = copy(obj)
       
      %   COPY -- Create a copy of the current instance.
      %
      %     See also fcat/fcat
      %
      %     OUT:
      %       - `B` (fcat)
      
      B = fcat( cat_api('copy', obj.id) );
      B.displaymode = obj.displaymode;
    end
    
    function obj = setdisp(obj, mode)
      
      %   SETDISP -- Control display mode.
      %
      %     setdisp( obj, 'short' ) displays a compacted view of the
      %     contents of the object.
      %
      %     setdisp( obj, 'full' ) displays the full contents of `obj` as
      %     if it were a cell array of strings.
      %
      %     setdisp( obj, 'auto' ) displays 'full' when the number of rows
      %     is less than 100, and 'short' otherwise.
      %
      %     See also fcat/cellstr, fcat/categorical
      %
      %     IN:
      %       - `mode` ({'short', 'full', 'auto'})
      
      modes = fcat.DISPLAY_MODES;
      if ( ~ischar(mode) || ~any(strcmp(modes, mode)) )
        error( 'Invalid display mode. Options are: \n\n%s', strjoin(modes, ' | ') );
      end
      obj.displaymode = mode;
    end
    
    function disp(obj, cls)
      
      %   DISP -- Pretty-print the object's contents.
      %
      %     See also fcat/setdisp, fcat/fcat, fcat/getcats
      
      desktop_exists = usejava( 'desktop' );
      
      if ( nargin < 2 )
        cls = class( obj );
      end
      
      if ( desktop_exists )
        link_str = sprintf( '<a href="matlab:helpPopup %s/%s">%s</a>' ...
          , cls, cls, cls );
      else
        link_str = cls;
      end
      
      if ( ~isvalid(obj) )
        fprintf( 'Handle to deleted %s instance.\n\n', link_str );
        return;
      end
      
      sz_m = size( obj, 1 );
      sz_n = size( obj, 2 );
      
      if ( desktop_exists )
        sz_str = sprintf( '%d×%d', sz_m, sz_n );
      else
        sz_str = sprintf( '%d-by-%d', sz_m, sz_n );
      end
      
      if ( strcmp(obj.displaymode, 'short') )
        dispshort( obj, desktop_exists, link_str, sz_str );
        return;
      end
      
      if ( strcmp(obj.displaymode, 'full') )
        dispfull( obj, desktop_exists, link_str, sz_str );
        return;
      end
      
      if ( strcmp(obj.displaymode, 'auto') )
        if ( size(obj, 1) > fcat.MAX_ROWS_DISPLAY_FULL )
          dispshort( obj, desktop_exists, link_str, sz_str );
        else
          dispfull( obj, desktop_exists, link_str, sz_str );
        end
        return;
      end
      
      error( 'Unrecognized display mode "%s".', obj.displaymode );      
    end
    
    %
    %   CONVERSION
    %
    
    function [C, F] = cellstr(obj)
      
      %   CELLSTR -- Convert to cell array of strings.
      %
      %     C = cellstr( obj ) returns an MxN cell array of strings `C`,
      %     whose rows are observations and columns are categories.
      %
      %     [C, F] = ... also returns a 1xN cell array of strings `F`
      %     identifying the columns of `C`.
      %
      %     See also fcat/fullcat, fcat/fcat
      %
      %     OUT:
      %       - `C` (cell array of strings)
      %       - `F` (cell array of strings)
      
      F = getcats( obj );
      C = fullcat( obj, F );
    end
    
    function [C, F] = categorical(obj)
      
      %   CATEGORICAL -- Convert to Matlab categorical array.
      %
      %     See also fcat/cellstr
      %
      %     OUT:
      %       - `C` (categorical)
      %       - `F` (cell array of strings)
      
      [N, labs, ids] = cat_api( 'to_numeric_mat', obj.id );
      C = categorical( N, ids, labs );
      F = getcats( obj );
    end
  end
  
  methods (Access = private)
    
    function dispfull(obj, desktop_exists, link_str, sz_str)
      
      %   DISPFULL -- Display complete contents.
      
      fprintf( '  %s %s array\n\n', sz_str, link_str );
      disp( categorical(obj) );
    end
    
    function dispshort(obj, desktop_exists, link_str, sz_str)
      
      %   DISPSHORT -- Display a summarized version of contents.
      
      cats = getcats( obj );
      
      if ( numel(cats) == 0 )
        addtl_str = 'with 0 categories';
      else
        addtl_str = 'with categories:';
      end
      
      max_labs = 5;
      max_cats = 10;
      
      fprintf( '  %s %s %s', sz_str, link_str, addtl_str );
      
      if ( numel(cats) > 0 )
        fprintf( '\n' );
      end
      
      n_digits = cellfun( @numel, cats );
      
      n_cats_disp = min( numel(cats), max_cats );
      
      max_n_digits = max( n_digits(1:n_cats_disp) );
      
      for i = 1:n_cats_disp
        c_cat = cats{i};
        
        labs = incat( obj, c_cat );
        
        amt_pad = max_n_digits - numel( c_cat );
        cat_space = repmat( ' ', 1, amt_pad );
        
        n_labs = numel( labs );
        n_disp = min( n_labs, max_labs );
        
        if ( desktop_exists )
          fprintf( '\n  %s<strong>%s</strong>:', cat_space, c_cat );
        else
          fprintf( '\n  %s%s:', cat_space, c_cat );
        end
        
        lab_str = strjoin( labs(1:n_disp), ', ' );
        
        if ( n_disp < n_labs )
          lab_str = sprintf( '%s ..', lab_str );
        end
        
        lab_str = sprintf( '[%s]', lab_str );
        
        fprintf( ' %s', lab_str );
      end
      
      if ( numel(cats) > n_cats_disp )
        if ( max_n_digits > 1 )
          c_cat = '..';
          amt_pad = max_n_digits - numel( c_cat );
          cat_space = repmat( ' ', 1, amt_pad );
        else
          c_cat = '.';
          cat_space = '';
        end
        if ( desktop_exists )
          fprintf( '\n  %s<strong>%s</strong>|', cat_space, c_cat );
        else
          fprintf( '\n  %s%s|', cat_space, c_cat );
        end
      end
      
      fprintf( '\n\n' );
    end
  end
  
  methods (Static = true, Access = private)
    
    function validate_constructor_signature(stack)
      
      %   VALIDATE_CONSTRUCTOR_SIGNATURE -- Ensure constructor is 
      %     appropriately called.
      
      if ( numel(stack) == 1 )
        error( 'Invalid input to fcat().' );
      end
      
      if ( numel(stack) >= 2 )
        if ( ~strcmp(stack(2).file, 'fcat.m') || ...
            ~strcmp(stack(2).name, 'fcat.copy') )
          error( 'Invalid input to fcat().' );
        end
      end
    end
  end
  
  methods (Static = true, Access = public)
    
    function obj = with(cats, sz)
      
      %   WITH -- Create fcat with categories.
      %
      %     obj = fcat.with( {'cat1', 'cat2'} ) creates a new fcat object
      %     with categories 'cat1' and 'cat2'.
      %
      %     obj = fcat.with( ..., 1000 ) additionally resizes the object to
      %     contain 1000 rows.
      %
      %     IN:
      %       - `cats` (char, cell array of strings)
      %       - `sz` (uint64) |OPTIONAL|
      %     OUT:
      %       - `obj` (fcat)
      
      obj = requirecat( fcat(), cats );
      
      if ( nargin == 2 )
        resize( obj, sz );
      end
    end
    
    function obj = from(varargin)
      
      %   FROM -- Create fcat from compatible source.
      %
      %     C = fcat.from( c, cats ) creates a fcat object
      %     from the Matlab categorical array or cell array of strings
      %     `c` and `cats`. `c` is an MxN categorical array or cell array
      %     of strings whose columns correspond to the categories in 
      %     `cats`.
      %
      %     See also fcat/fcat
      %
      %     IN:
      %       - `varargin`
      %     OUT:
      %       - `obj` (fcat)
      
      narginchk( 1, 2 );
      
      arr = varargin{1};
      
      if ( nargin == 1 )        
        if ( isa(arr, 'categorical') || isa(arr, 'cell') )
          cats = arrayfun( @(x) sprintf('cat%d', x), 1:size(arr, 2), 'un', false );
        end
        
        if ( isa(arr, 'SparseLabels') )
          [arr, cats] = label_mat( arr );
        end
      else
        cats = varargin{2};
      end
        
      if ( ~iscellstr(cats) && ~isa(cats, 'categorical') )
        error( 'Categories must be cell array of strings, or categorical.' );
      end

      if ( numel(unique(cats)) ~= numel(cats) )
        error( 'Categories cannot contain duplicates.' );
      end

      if ( numel(cats) ~= size(arr, 2) )
        error( 'Supply one category for each column of the labels matrix.' );
      end

      if ( ~ismatrix(arr) )
        error( 'Input array must be a matrix.' );
      end

      if ( isa(cats, 'categorical') )
        cats = cellstr( cats );
      end

      if ( isa(arr, 'categorical') )
        arr = cellstr( arr );
      end

      if ( iscellstr(arr) )
        obj = fcat();
        try
          requirecat( obj, cats );
          for i = 1:numel(cats)
            setcat( obj, cats{i}, arr(:, i) );
          end
        catch err
          delete( obj );
          fprintf( ['\n The following error occurred when\n attempting to create' ...
            , ' an fcat object\n from cellstr or categorical input:\n\n'] );
          throw( err );
        end
        return;
      end

      error( 'Cannot convert to fcat from objects of type "%s"', class(arr) );
    end
  end
end