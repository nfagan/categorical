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
      
      %   FCAT -- Create empty fcat object.
      %
      %     FCAT objects are meant to group and identify subsets of data, 
      %     in the vein of categorical arrays.
      %
      %     FCAT objects are essentially categorical matrices whose
      %     elements are unique across columns. In this way, each column of 
      %     an FCAT object constitutes a category (or dimension) with an 
      %     arbitrary number of levels (or labels). Rows of observations 
      %     can then be identified by a given combination of labels across 
      %     all categories.
      %
      %     The FCAT constructor generates an empty object into which
      %     categories and labels can be inserted. To directly construct an
      %     FCAT object with categories set to values, see the static
      %     method `create`. To construct an FCAT object with empty 
      %     categories, see the static method `with`. To convert to FCAT
      %     from a compatible source, such as a cell mtarix of strings or 
      %     categorical matrix, see the static method `from`.
      %
      %     EX 1 //
      %
      %     f = setcat( addcat(fcat, 'cities'), 'cities', {'ny' 'la' 'sf'} )
      %     find( f, {'ny' 'la'} )
      %
      %     EX 2 //
      %
      %     f1 = repmat( fcat.create( ...
      %         'cities', {'NYC', 'NYC', 'Santa Fe'} ...
      %       , 'states', {'NY', 'NY', 'NM'} ...
      %       , 'attractions', {'met', 'moma', 'nmart'} ...
      %     ), 20 )
      %
      %     [y, I, C] = keepeach( copy(f1), getcats(f1) )
      %
      %     See also fcat/create, fcat/from, fcat/with, fcat/findall
      
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
    
    function tf = progenitorsmatch(obj, B)
      
      %   PROGENITORSMATCH -- True if two fcats have the same source.
      %
      %     Internally, fcat objects house matrices of uint32 ids mapped to
      %     string labels. Ids are chosen randomly upon insertion of new
      %     labels, such that two objects with semantically identical
      %     contents might have different string-label to uint32 id
      %     mappings. Reconciling these potential differences can be
      %     expensive during `append`, `assign`, etc. operations between
      %     objects, and is unnecessary in the case that the mappings
      %     match. fcat objects thus keep track of their progenitor -- the
      %     source of their label mapping -- and employ faster between-
      %     object functions if those progenitors match.
      %
      %     See also fcat/eq, fcat/findall
      %
      %     IN:
      %       - `B` (/any/)
      %     OUT:
      %       - `tf` (logical)

      if ( ~isa(obj, 'fcat') || ~isa(B, 'fcat') )
        tf = false;
        return;
      end
      
      tf = cat_api( 'progenitors_match', obj.id, B.id );
    end
    
    function tf = eq(obj, B)
      
      %   EQ -- True if two fcat objects have equal contents.
      %
      %     A == B returns true if `A` and `B` are both fcat objects with
      %     matching labels and categories, and with equivalent label
      %     matrices.
      %
      %     Use `isequal` to determine whether A and B are handles to the
      %     same underlying object.
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
      
      %   NUMEL -- Get the number of elements in the object.
      %
      %     N = numel( obj ) is equivalent to N = prod( size(obj) );
      %
      %     See also fcat/size, fcat/length
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = prod( size(varargin{1}), 'native' );  %#ok<PSIZE>
    end
    
    function tf = isempty(obj)
      
      %   ISEMPTY -- True if the object has 0 rows.
      %
      %     See also fcat/size, fcat/length
      %
      %     OUT:
      %       - `tf` (logical)
      
      tf = length( obj ) == 0;      %#ok<ISMT>
    end
    
    function l = length(obj)
      
      %   LENGTH -- Get the number of rows in the object.
      %
      %     l = length( obj ) returns the number of rows in `obj`, and is
      %     equivalent to `size(obj, 1)`.
      %
      %     See also fcat/size, fcat/numel
      %
      %     OUT:
      %       - `l` (uint64)
      
      l = size( obj, 1 );
    end
    
    function sz = size(obj, dim)
      
      %   SIZE -- Get size of the object.
      %
      %     S = size( obj ) returns the [M, N] size of `obj`. `M` is the 
      %     number of rows in `obj`; `N` is the number of caegories.
      %
      %     S = size( obj, DIM ) returns the size of `obj` in dimension
      %     `DIM`.
      %
      %     For the sake of stylistic consistency, the size of `obj` in
      %     dimensions > 2 is 1.
      %
      %     See also fcat/numel, fcat/length, fcat/getlabs
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
          sz = uint64( 1 );
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
      %     See also fcat/size, fcat/nlabs, fcat/length
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = cat_api( 'n_cats', obj.id );      
    end
    
    function c = count(obj, labels, inds)
      
      %   COUNT -- Count the number of rows associated with labels.
      %
      %     c = count( obj, 'a' ) returns the number of rows identified by
      %     the label 'a'.
      %
      %     c = count( obj, labels ) returns counts for each label in the
      %     cell array of strings `labels`.
      %
      %     c = count( ..., inds ) searches only rows identified by the
      %     uint64 index vector `inds`.
      %
      %     See also fcat/find, fcat/prune
      %
      %     IN:
      %       - `labels` (char, cell array of strings)
      %       - `inds` (uint64) |OPTIONAL|
      %     OUT:
      %       - `c` (uint64)
      
      if ( nargin == 2 )
        c = cat_api( 'count', obj.id, labels );
      else
        c = cat_api( 'count', obj.id, labels, uint64(inds) );
      end
    end
    
    function [c, C] = countrows(obj, categories)
      
      %   COUNTROWS -- Count rows identified by label combinations.
      %
      %     c = countrows( obj, {'cities', 'states'} ) returns the number
      %     of rows identified by each combination of 'cities' and
      %     'states'.
      %
      %     [ ..., C ] also returns the combinations `C` as a cell array of
      %     strings. Each column `i` of `C` is associated with each `c(i)`.
      %
      %     See also fcat/keepeach, fcat/findall, fcat/count
      %
      %     IN:
      %       - `categories` (cell array of strings, char)
      %     OUT:
      %       - `c` (uint64)
      %       - `C` (cell array of strings)
      
      if ( nargout == 1 )
        I = findall( obj, categories );
      else
        [I, C] = findall( obj, categories );
      end
      
      c = cellfun( @numel, I );
    end
    
    function obj = resize(obj, to)
      
      %   RESIZE -- Expand or contract object.
      %
      %     resize( obj, 100 ) expands or contracts `obj` to contain 100
      %     rows. If `obj` originally had fewer than 100 rows, additional
      %     rows will contain the collapsed expression for each category.
      %     If `obj` originally had more than 100 rows, it will now contain
      %     the first 100 rows. If `obj` has no categories, resizing has no
      %     effect.
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
      %     repeat( obj, 1 ) is equivalent to [ obj; obj ];
      %     repeat( obj, 0 ) has no effect.
      %
      %     See also fcat/resize, fcat/repmat
      %
      %     IN:
      %       - `n_times` (uint64, double)
      
      cat_api( 'repeat', obj.id, uint64(n_times) );      
    end
    
    function obj = repmat(obj, varargin)
      
      %   REPMAT -- Repeat array contents.
      %
      %     repmat( obj, 2 ) is equivalent to [ obj; obj ];
      %     repmat( obj, 1 ) has no effect.
      %     repmat( obj, 0 ) is equivalent to keep( obj, [] );
      %
      %     See also fcat/repeat, fcat/resize
      %
      %     IN:
      %       - `varargin`
      
      N = varargin{1};
      
      %   replicate behavior of repmat, which creates an empty matrix if a
      %   size along a dimension is 0.
      if ( N == 0 )
        keep( obj, [] );
        return;
      end
      
      repeat( obj, N-1 );
    end
    
    function obj = repset(obj, cat, to)

      %   REPSET -- Replicate and assign labels to full subset of category.
      %
      %     repset( obj, C, TO ) where `C` is a category name, and `TO`
      %     is a cell array of string labels, replicates the contents of 
      %     `obj` N times, where N is equal to the number of elements in 
      %     `TO`. For each replication `i`, the contents of the category 
      %     `C` will be set to `TO{i}`.
      %
      %     EX //
      %
      %     f = fcat.create( 'state', 'NY' );
      %     addcat( f, 'city' );
      %     repset( f, 'city', {'NYC', 'Buffalo', 'Albany'} )
      %
      %     See also fcat/repmat, fcat/setcat, fcat/resize
      %
      %     IN:
      %       - `cat` (char)
      %       - `to` (cell array of strings, char)

      if ( ~iscell(to) ), to = { to }; end
      
      assert( iscellstr(to), 'Input must be a cell array of strings, or char.' );

      N = length( obj );
      repmat( obj, numel(to) );
      rowsi = 1:N;

      for i = 1:numel(to)
        setcat( obj, cat, to{i}, rowsi + ((i-1)*N) );
      end
    end
    
    function obj = reshape(obj, varargin)
      
      %   RESHAPE -- Reshaping fcat objects is not supported.
      %
      %     See also fcat/resize
      
      error( 'Reshaping fcat objects is not supported. See `fcat/resize`.' );
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
      %     Reference with curly braces "{}" is also supported in the same
      %     manner as with parentheses "()". In this case, however, the 
      %     output is a categorical matrix, rather than a cell matrix of 
      %     strings.
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
              is_colon_idx = all( strcmp(index_or_colon, ':') );
              
              if ( isnumeric(category_or_inds) || is_colon_cat )
                %
                % obj(1, 'a') | obj(:, 'a') | obj(1, {'a', 'b'})
                %
                if ( ~is_colon_idx && ~isnumeric(index_or_colon) )
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
          case '{}'
            %
            % f{:} | f{'days'} | f{{'days', 'doses'}}
            %
            if ( n_subs == 1 )
              if ( strcmp(subs{1}, ':') )
                varargout{1} = categorical( obj );
              else
                varargout{1} = categorical( incat(obj, subs{1}) );
              end
              return;
            end
            
            %
            % f{1, :} | f{:, :} | f{1, 2} | f{1, 'cities'} ..
            %
            
            assert( n_subs == 2, 'Too many subscripts.' );
            
            rows = subs{1};
            cats = subs{2};
            
            if ( numel(cats) == 1 && strcmp(cats, ':') )
              cats = getcats( obj );
            end
            
            if ( numel(rows) == 1 && strcmp(rows, ':') )
              varargout{1} = categorical( obj, cats );
              return;
            end
            
            varargout{1} = categorical( obj, cats, rows );
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
            
            error( 'Unrecognized property or method "%s".', subs );
          otherwise
            error( 'Referencing with "%s" is not supported.', type );
        end
      catch err
        throwAsCaller( err );
      end
    end
    
    function n = numArgumentsFromSubscript(obj, a, b)
      n = 1;
    end
    
    function tf = trueat(obj, indices)
      
      %   TRUEAT -- Create logical index assigned to true at indices.
      %
      %     tf = trueat( obj, [1, 2] ) creates an Mx1 logical index
      %     assigned to true at rows [1] and [2]. M is equal to 
      %     size( obj, 1 ).
      %
      %     See also fcat/find, fcat/keep
      %
      %     IN:
      %       - `indices` (uint64)
      %     OUT:
      %       - `tf` (logical)
      
      tf = false( size(obj, 1), 1 );
      tf(indices) = true;
    end
    
    function [obj, I] = only(obj, labels)
      
      %   ONLY -- Retain rows identified by label or label combination.
      %
      %     only( obj, 'a' ) retains rows identified by the label 'a'.
      %     only( obj, {'a', 'b'} ) retains rows identified by the label
      %     combination {'a', 'b'}. If 'a' and 'b' reside in the same
      %     category, `obj` will have rows associated with 'a' OR 'b'. If
      %     'a' and 'b' reside in different categories, `obj` will have
      %     rows associated with 'a' AND 'b'.
      %
      %     [..., I] = only(obj, ...) also returns `I`, the uint64 indices 
      %     used to select rows of `obj`.
      %
      %     EX //
      %
      %     f = fcat.create( 'a', {'a', 'b'}, 'c', {'c', 'd'} )
      %     f1 = only( copy(f), {'a', 'b'} )
      %     f2 = only( copy(f), {'a', 'd'} )
      %     f3 = only( copy(f), {'a', 'c'} )
      %
      %     See also fcat/keep, fcat/find
      %
      %     IN:
      %       - `labels` (cell array of strings, char)
      %     OUT:
      %       - `obj` (fcat)
      %       - `I` (uint64)
      
      I = find( obj, labels );
      keep( obj, I );
    end
    
    function [obj, to_keep] = onlynot(obj, labels)
      
      %   ONLYNOT -- Retain rows not identified by label or label combination.
      %
      %     onlynot( obj, 'a' ) removes rows identified by the label 'a'.
      %     onlynot( obj, {'a', 'b'} ) removes rows identified by the label
      %     combination {'a', 'b'}. If 'a' and 'b' reside in the same
      %     category, `obj` will contain neither 'a' nor 'b'. If 'a' and
      %     'b' reside in different categories, only rows identified by 'a'
      %     AND 'b' will be removed.
      %
      %     [..., I] = onlynot(obj, ...) also returns `I`, the uint64 
      %     indices of the rows of `obj` that were kept.
      %
      %     Use `setdiff( 1:rows(obj), I )` to get the indices of the
      %     rows of `obj` that were removed.
      %
      %     EX //
      %
      %     f = fcat.create( 'a', {'a', 'a'}, 'c', {'c', 'd'} )
      %     f1 = onlynot( copy(f), 'a' )
      %     f2 = onlynot( copy(f), {'a', 'c'} )
      %
      %     See also fcat/only, fcat/keep, fcat/find
      %
      %     IN:
      %       - `labels` (cell array of strings, char)
      %     OUT:
      %       - `obj` (fcat)
      %       - `I` (uint64)
      
      to_rm = find( obj, labels );
      to_keep = setdiff( 1:size(obj, 1), to_rm );
      keep( obj, to_keep );
    end
    
    function [obj, I] = remove(obj, labels)
      
      %   REMOVE -- Remove rows associated with any among labels.
      %
      %     remove( obj, 'a' ) removes rows identified by the label 'a'.
      %     remove( obj, {'a', 'b'} ) removes rows identified by labels 'a'
      %     OR 'b'.
      %
      %     [..., I] = remove(obj, ...) also returns `I`, the uint64 
      %     indices of the rows of `obj` that were kept.
      %
      %     Use `setdiff( 1:rows(obj), I )` to get the indices of the
      %     rows of `obj` that were removed.
      %
      %     EX //
      %
      %     f = fcat.create( 'a', {'a', 'b'}, 'c', {'c', 'd'} )
      %     f1 = remove( copy(f), 'a' )
      %     f2 = remove( copy(f), {'a', 'd'} )
      %
      %     See also fcat/keep, fcat/find, fcat/only, fcat/onlynot
      %
      %     IN:
      %       - `labels` (cell array of strings, char)
      %     OUT:
      %       - `obj` (fcat)
      %       - `I` (uint64)
      
      I = cat_api( 'remove', obj.id, labels );
    end
    
    function obj = keep(obj, indices)
      
      %   KEEP -- Retain rows at indices.
      %
      %     keep( obj, 1 ) retains the first row of `obj`.
      %     keep( obj, [1, 3] ) retains the first and third rows of `obj`.
      %     keep( obj, [3, 1] ) retains the third and first rows of `obj`,
      %     in that order.
      %
      %     See also fcat/fcat, fcat/findall
      %
      %     IN:
      %       - `indices` (uint64)
      
      cat_api( 'keep', obj.id, uint64(indices) );     
    end
    
    function obj = empty(obj)
      
      %   EMPTY -- Retain 0 rows.
      %
      %     See also fcat/keep
      
      cat_api( 'empty', obj.id );
    end
    
    function [obj, I, C] = keepeach(obj, categories, inds)
      
      %   KEEPEACH -- Retain one row for each combination of labels.
      %
      %     keepeach( obj, {'cities', 'states'} ) retains one row of labels
      %     for each combination of categories 'cities' and 'states'.
      %     Additional categories of `obj` are collapsed if, for a given
      %     combination of 'cities' and 'states', more than one label of
      %     the category is identified by that combination.
      %
      %     keepeach( ..., inds ) restricts the search to the subset of
      %     rows identified by the uint64 index vector `inds`.
      %
      %     [..., I] = ... also returns `I`, a cell array of indices
      %     identifying the rows of `obj` associated with each row of `f`.
      %
      %     [..., C] = ... also returns `C`, the cell matrix of label
      %     combinations associated with each row of `f`.
      %
      %     EX //
      %
      %     f1 = fcat.create( ...
      %         'cities', {'NYC', 'NYC', 'Santa Fe'} ...
      %       , 'states', {'NY', 'NY', 'NM'} ...
      %       , 'attractions', {'met', 'moma', 'nmart'} ...
      %     )
      %
      %     f2 = keepeach( copy(f1), 'cities' )
      %     f3 = keepeach( copy(f1), 'attractions' )
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
        if ( nargin == 3 )
          [I, C] = cat_api( 'keep_eachc', obj.id, categories, uint64(inds) );
        else
          [I, C] = cat_api( 'keep_eachc', obj.id, categories );
        end
        if ( ~ischar(categories) && numel(categories) > 0 )
          C = reshape( C, numel(categories), numel(C) / numel(categories) );
        end
      else
        if ( nargin == 3 )
          I = cat_api( 'keep_each', obj.id, categories, uint64(inds) );
        else
          I = cat_api( 'keep_each', obj.id, categories );
        end
      end
    end
    
    function obj = unique(obj)
      
      %   UNIQUE -- Retain unique rows.
      %
      %     unique( obj ) keeps the unique rows of `obj`.
      %
      %     See also fcat/combs, categorical/unique
      
      keepeach( obj, getcats(obj) );
    end
    
    function C = combs(obj, categories, inds)
      
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
      %     C = combs( ..., inds ) returns the combinations in the subset
      %     of rows identified by the uint64 index vector `inds`.
      %
      %     See also fcat/findall
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %       - `inds` (uint64) |OPTIONAL|
      %     OUT:
      %       - `cmbs` (uint32)
      
      if ( nargin == 1 )
        categories = getcats( obj );
      end
      
      if ( nargin == 3 )
        [~, C] = findall( obj, categories, inds );
      else
        [~, C] = findall( obj, categories );
      end
    end
    
    function [I, C] = findall(obj, categories, inds)
      
      %   FINDALL -- Get indices of combinations of labels in categories.
      %
      %     I = findall( obj, {'a', 'b'} ) returns a cell array of uint64 
      %     indices `I`, where each index in I identifies a unique
      %     combination of labels in categories 'a' and 'b'.
      %
      %     I = findall( ..., inds ) searches the subset of rows identified
      %     by the uint64 index vector `inds`.
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
      %       - `inds` (uint64) |OPTIONAL|
      %     OUT:
      %       - `I` (cell array of uint64)
      %       - `C` (cell array of strings)
      
      if ( nargin < 2 )
        categories = getcats( obj );
      end
      
      if ( nargout > 1 )
        if ( nargin == 3 )
          [I, C] = cat_api( 'find_allc', obj.id, categories, uint64(inds) );
        else
          [I, C] = cat_api( 'find_allc', obj.id, categories );
        end
        
        if ( ~ischar(categories) && numel(categories) > 0 )
          C = reshape( C, numel(categories), numel(C) / numel(categories) );
        else
          C = C(:)';
        end
      else
        if ( nargin == 3 )
          I = cat_api( 'find_all', obj.id, categories, uint64(inds) );
        else
          I = cat_api( 'find_all', obj.id, categories );
        end
      end
    end
    
    function I = find(obj, labels, inds)
      
      %   FIND -- Get indices associated with label or label combination.
      %
      %     I = find( obj, 'a' ) returns indices of rows identified by the 
      %     label 'a'.
      %
      %     I = find( obj, {'a', 'b'} ) returns indices of rows identified 
      %     by the label combination {'a', 'b'}. If 'a' and 'b' reside in 
      %     the same category, `I` will index rows associated with 'a' OR 
      %     'b'. If 'a' and 'b' reside in different categories, `I` will 
      %     index rows associated with 'a' AND 'b'.
      %
      %     I = find( ..., inds ) restricts the search to the subset of
      %     rows identified by the uint64 index vector `inds`.
      %
      %     Formally, within a category, indices are calculated via an 
      %     `or` operation; across categories, indices are calculated via 
      %     an `and` operation.
      %
      %     EX //
      %
      %     f = fcat.create( 'a', {'a', 'b'}, 'c', {'c', 'd'} )
      %     find( f, {'a', 'b'} )
      %     find( f, {'a', 'd'} )
      %     find( f, {'a', 'c'} )
      %
      %     See also fcat/findall, fcat/findor, fcat/getlabs, fcat/getcats
      %
      %     IN:
      %       - `labels` (cell array of strings, char)
      %       - `inds` (uint64) |OPTIONAL|
      %     OUT:
      %       - `inds` (uint32)
      
      if ( nargin < 3 )
        I = cat_api( 'find', obj.id, labels );
      else
        I = cat_api( 'find', obj.id, labels, uint64(inds) );
      end
    end
    
    function I = findor(obj, labels, inds)
      
      %   FINDOR -- Get indices associated with any among labels.
      %
      %     I = findor( obj, {'a', 'b', 'c'} ) returns indices associated
      %     with any among 'a', 'b' and 'c'. If all labels reside in the 
      %     same category, the output is equivalent to `find`.
      %
      %     I = findor( ..., inds ) searches the subset of rows identified 
      %     by the uint64 index vector `inds`.
      %
      %     EX //
      %
      %     f = fcat.create( 'a', {'a', 'b'}, 'c', {'c', 'd'} )
      %     find( f, {'a', 'd'} )
      %     findor( f, {'a', 'd'} )
      %
      %     See also fcat/find, fcat/findall
      %
      %     IN:
      %       - `labels` (cell array of strings, char)
      %       - `inds` (uint64) |OPTIONAL|
      %     OUT:
      %       - `inds` (uint32)
      
      if ( nargin < 3 )
        I = cat_api( 'find_or', obj.id, labels );
      else
        I = cat_api( 'find_or', obj.id, labels, uint64(inds) );
      end
    end
    
    function C = getcats(obj, flag)
     
      %   GETCATS -- Get category names.
      %
      %     C = getcats( obj ); returns the category names of `obj` as a
      %     cell array of strings.
      %
      %     C = getcats( obj, FLAG ); where `FLAG` is one of 'uniform' or
      %     'nonuniform' returns only the uniform or non-uniform category
      %     names of `obj`, respectively. A uniform category is one for
      %     which all rows of the category are set to the same label.
      %
      %     See also fcat/getlabs, fcat/fcat
      %
      %     IN:
      %       - `flag` (char) |OPTIONAL|
      %     OUT:
      %       - `C` (cell array of strings)
      
      if ( nargin == 1 )
        C = cat_api( 'get_cats', obj.id );
        return;
      end
      
      if ( strncmpi('uniform', flag, numel(flag)) && numel(flag) > 1 )
        C = cat_api( 'get_uniform_cats', obj.id );
      elseif ( strncmpi('nonuniform', flag, numel(flag)) && numel(flag) > 1 )
        C = setdiff( getcats(obj), cat_api('get_uniform_cats', obj.id) );
      else
        error( 'Flag must be one of:\n\n%s', strjoin({'uniform', 'nonuniform'}, ' | ') );
      end
    end
    
    function C = categories(obj, varargin)
      
      %   CATEGORIES -- Get category names.
      %
      %     See also fcat/getcats, fcat/getlabs, fcat/fcat
      %
      %     OUT:
      %       - `C` (cell array of strings)
      
      C = getcats( obj, varargin{:} );
    end
    
    function L = getlabs(obj)
      
      %   GETLABS -- Get label names.
      %
      %     See also fcat/getcats, fcat/fcat
      %
      %     OUT:
      %       - `L` (cell array of strings)
      
      L = cat_api( 'get_labs', obj.id );      
    end
    
    function id = getid(obj)
      
      %   GETID -- Get unique instance id.
      %
      %     See also fcat/getlabs
      %
      %     OUT:
      %       - `id` (uint64)
      
      id = obj.id;
    end
    
    function tf = haslab(obj, labels)
      
      %   HASLAB -- True if the label(s) exists.
      %
      %     See also fcat/hascat, fcat/fcat
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
      %     See also fcat/haslab, fcat/fcat
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
      %     See also fcat/fullcat, fcat/fcat
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
      %     C = incat( obj, 'cat1' ) returns the labels in 'cat1'.
      %
      %     C = incat( obj, {'cat1', 'cat2'} ) returns the labels in 'cat1'
      %     and 'cat2'. The order of labels in `C` is undefined.
      %
      %     See also fcat/fullcat
      %
      %     IN:
      %       - `category` (char)
      %     OUT:
      %       - `C` (cell array of strings)
      
      if ( ischar(category) )
        C = cat_api( 'in_cat', obj.id, category );
      else
        C = cat_api( 'in_cats', obj.id, category );
      end
    end
    
    function str = joincat(obj, categories, pattern)
      
      %   JOINCAT -- Join labels in categories to form a single string.
      %
      %     s = joincat( obj, {'cities', 'states'} ); forms a character 
      %     vector `s` from the labels in categories 'cities' and 'states'.
      %     Labels are joined with an underscore '_'. The order of labels
      %     is undefined.
      %
      %     s = joincat( ..., PATTERN ); uses PATTERN instead of an
      %     underscore.
      %
      %     See also fcat/incat, fcat/combs
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %       - `pattern` (char) |OPTIONAL|
      %     OUT:
      %       - `str` (char)
      
      if ( nargin < 3 ), pattern = '_'; end
      
      str = strjoin( incat(obj, categories), pattern );
    end
    
    function obj = addcat(obj, category)
      
      %   ADDCAT -- Add new category.
      %
      %     addcat( obj, 'cities' ) adds the category 'cities' to `obj`, if
      %     it does not already exist. If `obj` has more than 0 rows, the 
      %     category will be set to the collapsed expression for that 
      %     category.
      %
      %     If the collapsed expression is already present in a 
      %     different category, an error will be thrown and the category 
      %     will not be added.
      %
      %     The category name ':' is reserved to avoid conflict with 
      %     indexing operations that make use of the colon operator.
      %     Attempting to add ':' as a category is an error.
      %
      %     See also fcat/findall, fcat/fcat
      %
      %     IN:
      %       - `category` (cell array of strings, char)
      
      cat_api( 'add_cat', obj.id, category );      
    end
    
    function obj = requirecat(obj, category)
      
      %   REQUIRECAT -- Add category if it does not exist.
      %
      %     See also fcat/addcat, fcat/findall
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'require_cat', obj.id, category );
    end
    
    function obj = rmcat(obj, category)
      
      %   RMCAT -- Remove category(ies).
      %
      %     rmcat( obj, 'cities' ) removes the category 'cities' from 
      %     `obj`, throwing an error if it does not exist. 
      %
      %     If all categories are removed, `obj` becomes of size 0x0, such
      %     that isempty(obj) returns true.
      %
      %     See also fcat/addcat
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'rm_cat', obj.id, category );
    end
    
    function obj = renamecat(obj, from, to)
      
      %   RENAMECAT -- Rename category.
      %
      %     renamecat( obj, 'cities', 'city' ) renames the category
      %     'cities' to 'city'.
      %
      %     The to-be-renamed category must exist; the incoming category
      %     must not exist. Additionally, if the collapsed expression for 
      %     the incoming category is a present label, then it must reside 
      %     in the to-be-renamed category.
      %
      %     See also fcat/addcat, fcat/fcat, fcat/collapsecat
      %
      %     IN:
      %       - `from` (char)
      %       - `to` (char)
      
      cat_api( 'rename_cat', obj.id, from, to );
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
      %     Collapsed expressions are placeholder labels used generally to
      %     indicate the absence of a specific label in that category.
      %
      %     See also fcat/addcat, fcat/makecollapsed, fcat/keepeach
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'collapse_cat', obj.id, category );
    end
    
    function s = makecollapsed(obj, categories)
      
      %   MAKECOLLAPSED -- Make collapsed expression for category.
      %
      %     s = makecollapsed( obj, 'a' ) returns '<a>', the collapsed
      %     expression for category 'a'.
      %
      %     s = makecollapsed( obj, {'a', 'b'} ) returns {'<a>', '<b>'}
      %
      %     Collapsed expressions are placeholder labels used generally to
      %     indicate the absence of a specific label in that category.
      %
      %     See also fcat/collapsecat, fcat/keepeach, fcat/one, fcat/fcat
      %
      %     IN:
      %       - `categories` (cell array of strings, char)
      %     OUT:
      %       - `s` (cell array of strings, char)
      
      func = @(x) sprintf( '<%s>', x );
      
      if ( ischar(categories) )
        s = func( categories );
        return;
      end
      
      s = cellfun( func, categories, 'un', false );
    end
    
    function obj = one(obj)
      
      %   ONE -- Collapse all categories, and retain a single row.
      %
      %     one( obj ) reduces `obj` to a 1xN fcat with N categories. Each
      %     category with more than one label is collapsed to a single
      %     label.
      %
      %     If `obj` is of size 0xN, this function has no effect.
      %
      %     See also fcat/keepeach, fcat/none, fcat/fcat
      
      cat_api( 'one', obj.id );
    end
    
    function obj = none(obj)
      
      %   NONE -- Keep 0 rows, but retain labels.
      %
      %     none( obj ) keeps 0 rows of `obj`, but does not remove labels
      %     from `obj`, and is equivalent to keep( obj, [] ).
      %
      %     See also fcat/one, fcat/fcat
      
      keep( obj, [] );
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
        if ( ischar(category) )
          cat_api( 'set_cat', obj.id, category, to );
        else
          cat_api( 'set_cats', obj.id, category, to );
        end
      else
        if ( ischar(category) )
          cat_api( 'set_partial_cat', obj.id, category, to, uint64(at_indices) );
        else
          cat_api( 'set_partial_cats', obj.id, category, to, uint64(at_indices) );
        end
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
      %     fillcat( obj, 'cities', 'NY' ) assigns 'NY' to each row of
      %     category 'cities'.
      %
      %     See also fcat/setcat
      %
      %     IN:
      %       - `cat` (char)
      %       - `lab` (char)
      
      cat_api( 'fill_cat', obj.id, cat, lab );      
    end
    
    function obj = replace(obj, from, with)
      
      %   REPLACE -- Replace label(s) with label.
      %
      %     replace( obj, 'label1', 'label2' ); replaces occurrences of
      %     'label1' with 'label2'. If 'label2' exists in `obj`, it must be
      %     in the same category as 'label1'.
      %
      %     replace( obj, {'lab1', 'lab2'}, 'lab3' ); works as above, but
      %     for multiple labels.
      %
      %     See also fcat/fillcat, fcat/renamecat
      %
      %     IN:
      %       - `from` (cell array of strings, char)
      %       - `with` (char)
      
      cat_api( 'replace', obj.id, from, with );      
    end
    
    function [obj, n] = prune(obj)
      
      %   PRUNE -- Remove labels without rows.
      %
      %     prune( obj ) removes unused labels in `obj`, that is, labels
      %     that are not associated with any rows of `obj`. An unused label
      %     `L` is also one for which count(obj, L) returns 0.
      %
      %     [obj, n] = prune( obj ) also returns the number of labels that
      %     were removed.
      %
      %     See also fcat/keep, categorical/removecats
      %
      %     OUT:
      %       - `obj` (fcat)
      %       - `n` (uint64)
      
      n = cat_api( 'prune', obj.id );
    end
    
    function obj = append(obj, B, inds)
      
      %   APPEND -- Append another fcat object.
      %
      %     append( A, B ) appends the contents of `B` to `A`.
      %
      %     append( A, B, inds ) appends the subset of rows of `B`
      %     identified by the uint64 index vector `inds`. This syntax is
      %     equivalent to append( A, B(inds) ), but is generally much
      %     faster, since it avoids copying `B`.
      %
      %     Categories must match between objects; labels shared between 
      %     objects must reside in consistent categories.
      %
      %     See also fcat/join, fcat/append1, fcat/fcat
      %
      %     IN:
      %       - `B` (fcat)
      %       - `inds` (uint64) |OPTIONAL|
      
      if ( ~isa(obj, 'fcat') )
        error( 'Cannot append objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'fcat') )
        error( 'Cannot append objects of class "%s".', class(B) );
      end
      
      if ( nargin == 2 )
        cat_api( 'append', obj.id, B.id );
      else
        cat_api( 'append', obj.id, B.id, uint64(inds) );
      end
    end
    
    function obj = append1(obj, B, inds)
      
      %   APPEND1 -- Append single collapsed fcat object.
      %
      %     append1( A, B ) appends a single collapsed row of `B` to `A`,
      %     without modifying `B`. For each category in `A` and `B`, either
      %     the collapsed expression for the category, or the single label
      %     in the category (i.e., if it is uniform), will be added to `A`.
      %
      %     append1( A, B, I ) considers only the rows of `B` identified by
      %     the uint64 index vector `I`.
      %
      %     append1( A, B ) is the same as append( A, one(B(:)) ), but
      %     is generally much faster, since it avoids copying `B`.
      %
      %     append1( A, B, 1:10 ) is the same as append( A, one(B(1:10)) ).
      %
      %     EX //
      %
      %     A = fcat.example;
      %     B = fcat.example;
      %
      %     C = append1( A', B )
      %     D = append1( A', B, 1 )
      %     E = append1( A', B, find(B, 'image') )
      %
      %     See also fcat/one, fcat/append, fcat/collapsecat
      %
      %     IN:
      %       - `B` (fcat)
      %       - `inds` (uint64) |OPTIONAL|
      
      if ( ~isa(obj, 'fcat') )
        error( 'Cannot append objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'fcat') )
        error( 'Cannot append objects of class "%s".', class(B) );
      end
      
      if ( nargin == 2 )
        cat_api( 'append_one', obj.id, B.id );
      else
        cat_api( 'append_one', obj.id, B.id, uint64(inds) );
      end
    end
    
    function obj = merge(obj, varargin)
      
      %   MERGE -- Merge other's contents, overwriting present categories.
      %
      %     merge( A, B ) merges the contents of B into A. Categories
      %     of B not present in A are inserted into A; categories
      %     shared between A and B are set to B's contents. B must have the
      %     same number of rows of A, or else have a single row, in which
      %     case B is implicitly expanded to match the size of A.
      %
      %     merge( A, B, C ... ) merges the contents of B, C ... into A, as
      %     above. Categories shared between B, C ... are set to the 
      %     contents of the right-most argument.
      %
      %     EX //
      %
      %     A = fcat.create( 'date', datestr(now) );
      %     B = fcat.create( 'city', 'New York' );
      %     repmat( A, 10 );
      %     merge( A, B )
      %
      %     See also fcat/join, fcat/assign, fcat/setcat, fcat/fcat
      %
      %     IN:
      %       - `B` (fcat)
      
      if ( ~isa(obj, 'fcat') )
        error( 'Cannot merge objects of class "%s".', class(obj) );
      end
      
      try
        cellfun( @(x) assert(isa(x, 'fcat'), ['Cannot merge objects of' ...
          , ' class "%s".'], class(x)), varargin );
      catch err
        throwAsCaller( err );
      end
      
      N = numel( varargin );
      
      for i = 1:N
        cat_api( 'merge', obj.id, varargin{i}.id );
      end
    end
    
    function obj = mergenew(obj, varargin)
      
      %   MERGENEW -- Join other's contents, preserving present categories.
      %
      %     MERGENEW is not recommended. Use `join` instead.
      %
      %     See also fcat/join.
      %
      %     IN:
      %       - `B` (fcat)
      
      obj = join( obj, varargin{:} );
    end
    
    function obj = join(obj, varargin)
      
      %   JOIN -- Join other's contents, preserving present categories.
      %
      %     join( A, B ) adds into A categories of B not present in
      %     A. B must have the same number of rows of A, or else have a 
      %     single row, in which case B is implicitly expanded to match the
      %     size of A.
      %
      %     join( A, B ) is equivalent to merge( A, B ) when A and B
      %     have no shared categories.
      %
      %     join( A, B, C ... ) adds the contents of B, C ... into A, 
      %     as above.
      %
      %     EX //
      %
      %     A = fcat.create( 'date', datestr(now), 'city', 'Buffalo' );
      %     B = fcat.create( 'city', 'New York', 'state', 'NY' );
      %     repmat( A, 10 );
      %     C = join( copy(A), B )
      %     D = merge( copy(A), B )
      %
      %     See also fcat/merge, fcat/assign, fcat/setcat, fcat/fcat
      %
      %     IN:
      %       - `B` (fcat)
      
      if ( ~isa(obj, 'fcat') )
        error( 'Cannot join objects of class "%s".', class(obj) );
      end
      
      try
        cellfun( @(x) assert(isa(x, 'fcat'), ['Cannot join objects of' ...
          , ' class "%s".'], class(x)), varargin );
      catch err
        throwAsCaller( err );
      end
      
      N = numel( varargin );
      
      for i = 1:N
        cat_api( 'merge_new', obj.id, varargin{i}.id );
      end
    end
    
    function obj = extend(obj, varargin)
      
      %   EXTEND -- Alias for vertcat.
      %
      %     See also fcat/vertcat
      
      vertcat( obj, varargin{:} );
    end
    
    function obj = vertcat(obj, varargin)
      
      %   VERTCAT -- Append fcat object(s).
      %
      %     [A; B] appends B to A.
      %
      %     [A; B; C ...] appends B, C, ... to A.
      %
      %     Note that A will be modified unless explicitly copied. 
      %
      %     See also fcat/append
      %
      %     IN:
      %       - `B` (fcat)
      
      for i = 1:numel(varargin)
        append( obj, varargin{i} );
      end
    end
    
    function obj = horzcat(obj, varargin)
      
      %   HORZCAT -- Horizontal conatenation is not supported.
      %
      %     C = [A, B] is an error. Use C = [A; B], or append(A, B)
      %
      %     See also fcat/append, fcat/vertcat
      
      if ( numel(varargin) > 0 )
        error( ['Horizontal concatenation of fcat objects is not supported.' ...
          , ' Use vertical concatenation or the `append` method.'] );
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
      %     assign( obj, B, 1:10, 8 ) assigns row 8 of `B` to rows 1:10 of
      %     `obj`. In this case, the single row of `B` is implicitly
      %     repeated 10 times.
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
      %     Calling `clear obj` also deletes the object.
      %
      %     See also fcat/fcat
      
      cat_api( 'destroy', obj.id );
    end
    
    function obj = transpose(obj)
      
      %   TRANPOSE -- Transposition is not supported. Use ' to copy.
      %
      %     For clarity, B = A.'; is an error. Use B = A'; or B = copy(A);
      %
      %     See also fcat/copy, fcat/ctranspose
      
      error( ['Copying with .'' is not supported. Use '' or the copy' ...
        , ' function.'] );
    end
    
    function B = ctranspose(obj)
      
      %   CTRANSPOSE -- Overloaded operator copy.
      %
      %     B = A'; is syntactic sugar for B = copy( A );
      %
      %     See also fcat/copy
      %
      %     OUT:
      %       - `B` (fcat)
      
      B = copy( obj );
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
      %     if it were a categorical matrix.
      %
      %     setdisp( obj, 'auto' ) displays 'full' when the number of rows
      %     is less than 1000, and 'short' otherwise.
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
        link_str = sprintf( '<a href="matlab:helpPopup %s/%s" style="font-weight:bold">%s</a>' ...
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
      
      if ( sz_m == 0 )
        sz_str = sprintf( '%s empty', sz_str );
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
    
    function [tbl, rc] = tabular(obj, rows, cols)
      
      %   TABULAR -- Produce tabular cell matrix of indices.
      %
      %     T = tabular( obj, 'a', 'b' ) produces an MxN cell array of
      %     uint64 indices, where rows are composed of indices associated
      %     with each unique label in category 'a', and where columns are
      %     composed of indices associated with each unique label in
      %     category 'b'.
      %
      %     T = tabular( obj, {'a', 'b', 'c'} ) produces an array as
      %     above, except that columns are chosen automatically as the
      %     category with the fewest unique labels, and rows are the
      %     remaining categories.
      %
      %     [T, rc] = tabular(...) also returns cell arrays of fcat objects 
      %     that identify each row and column of `T`. The i-th row of rc{1}
      %     is the set of labels that identify the i-th row of `T`; the 
      %     j-th row of rc{2} identifies the j-th column of `T`.
      %
      %     Use the fcat.table function to convert the output of this
      %     function to a table.
      %
      %     See also fcat.table, fcat/findall
      %
      %     IN:
      %       - `rows` (cell array of strings, char)
      %       - `cols` (cell array of strings, char)
      
      if ( nargin == 1 )
        rows = getcats( obj );
      end
      
      if ( nargin < 3 || isempty(cols) )
        [rows, cols] = getrc( obj, mkcell(rows) );
      elseif ( isempty(rows) )
        [rows, cols] = getrc( obj, mkcell(cols) );
      else
        rows = mkcell( rows );
        cols = mkcell( cols );
      end
      
      rows = unique( rows );
      cols = unique( cols );
      
      spec = [ rows, cols ];
      
      [I, C] = findall( obj, spec );
      
      C = C';
      
      NR = numel( rows );
      NC = numel( cols );
      
      rowi = 1:NR;
      coli = NR+1:NR+NC;
     
      rowf = keepeach( fcat.from(C(:, rowi), rows), rows );
      colf = keepeach( fcat.from(C(:, coli), cols), cols );
      
      tbl = cell( length(rowf), length(colf) );
      
      for i = 1:numel(I)
        r = find( rowf, C(i, rowi) );
        c = find( colf, C(i, coli) );
        tbl{r, c} = I{i};
      end
      
      rc = { rowf, colf };
      
      function [r, c] = getrc(obj, cats)
        %   GETRC -- Get rows and cols, if some are emptied or unspecified.
        ns = cellfun( @(x) numel(findall(obj, x)), cats );
        [~, min_ind] = min( ns );
        keep_vec = true( size(ns) );
        keep_vec(min_ind) = false;
        
        r = cats( keep_vec );
        c = cats( min_ind );
        
        if ( isempty(r) && ~isempty(c) )
          r = c(1);
        elseif ( isempty(c) && ~isempty(r) )
          c = r(1);
        end
        
        r = r(:)';
        c = c(:)';
      end
      
      function x = mkcell(x)
        %   MKCELL -- Ensure input is cell row vector.
        if ( ~iscell(x) ), x = { x }; x = x(:)'; end
      end
    end
    
    %
    %   CONVERSION
    %
    
    function [C, cats] = cellstr(obj, cats, inds)
      
      %   CELLSTR -- Convert to cell array of strings.
      %
      %     C = cellstr( obj ) returns an MxN cell array of strings `C`,
      %     whose rows are observations and columns are categories.
      %
      %     C = cellstr( obj, CATS ) returns an MxN cell array of strings
      %     drawn from `CATS` categories. `CATS` can be a cell array of
      %     strings, or a numeric vector; the ordering of categories is
      %     consistent with the output of `getcats()`.
      %
      %     C = cellstr( ..., inds ) draws from rows identified by the
      %     uint64 index vector `inds`.
      %
      %     [C, cats] = ... also returns a 1xN cell array of strings `cats`
      %     identifying the columns of `C`.
      %
      %     See also fcat/categorical, fcat/fullcat, fcat/fcat
      %
      %     OUT:
      %       - `C` (cell array of strings)
      %       - `cats` (cell array of strings)
      
      if ( nargin == 1 )
        cats = getcats( obj );
        C = fullcat( obj, cats );
        return;
      end
      
      if ( isnumeric(cats) )
        c = getcats( obj );
        cats = c(cats);
      end
      
      if ( nargin < 3 )
        C = fullcat( obj, cats );
      else
        C = partcat( obj, cats, inds );
      end
    end
    
    function [C, cats] = categorical(obj, cats, inds)
      
      %   CATEGORICAL -- Convert to Matlab categorical matrix.
      %
      %     C = categorical( obj ) converts `obj` to a Matlab categorical
      %     matrix. Columns in `C` are in an order consistent with the
      %     output of `getcats(obj)`.
      %
      %     [..., cats] = categorical( obj ) also returns the categories of
      %     `obj` as a cell array of strings.
      %
      %     C = categorical( obj, 'cities' ) returns the category 'cities',
      %     only.
      %
      %     C = categorical( obj, 1 ) returns the first category in `obj`.
      %     The order of categories is consistent with the output of
      %     `getcats(obj)`.
      %
      %     C = categorical( ..., INDS ) returns the subset of rows at
      %     indices `INDS`.
      %
      %     Note that there are certain restrictions on the format of
      %     labels (levels) of a categorical matrix that do not apply to
      %     fcat objects, and these can complicate converting between
      %     the two. In particular, the empty character vector ('') is a
      %     valid fcat label, but an invalid categorical level.
      %     Additionally, the categorical constructor trims leading and
      %     trailing whitespace from its levels, whereas fcat objects
      %     preserve this whitespace. In these cases, use the cellstr()
      %     method to obtain an exact, Matlab-native representation of the 
      %     object's contents.
      %
      %     See also fcat/cellstr
      %
      %     IN:
      %       - `cats` (cell array of strings, numeric) |OPTIONAL|
      %       - `inds` (uint64) |OPTIONAL|
      %     OUT:
      %       - `C` (categorical)
      %       - `cats` (cell array of strings)
      
      if ( nargin == 1 )
        [N, labs, ids] = cat_api( 'to_numeric_mat', obj.id );
        cats = getcats( obj );
      else
        if ( isnumeric(cats) )
          c = getcats( obj );
          cats = c(cats);
        end
        if ( nargin == 2 )
          [N, labs, ids] = cat_api( 'to_numeric_mat', obj.id, cats );
        else
          [N, labs, ids] = cat_api( 'to_numeric_mat', obj.id, cats, uint64(inds) );
        end        
      end
      
      C = categorical( N, ids, labs );
    end
    
    function [d, f] = double(obj)
      
      %   DOUBLE -- Convert to Matlab double array.
      %
      %     See also fcat/categorical
      %
      %     OUT:
      %       - `d` (double)
      %       - `c` (cell array of strings)
      
      c = categorical( obj );
      d = double( c ); 
      f = categories( c );
    end
    
    function s = gather(obj, flag)
      
      %   GATHER -- Aggregate contents as struct.
      %
      %     s = gather( obj ) returns a struct `s` with fields 'labels' and
      %     'categories'. 'labels' is the categorical matrix that would be
      %     returned by `categorical( obj )`; 'categories' is the vector of
      %     category names identifying columns of 'labels'.
      %
      %     s = gather( obj, FLAG ) where FLAG is either 'categorical' or
      %     'cellstr', specifies the class of 'labels'.
      %
      %     EX //
      %
      %     x = gather( fcat.example );
      %     y = fcat.from( x.labels, x.categories )
      %
      %     See also fcat/cellstr, fcat/categorical, fcat.from
      %
      %     IN:
      %       - `flag` (char) |OPTIONAL|
      %     OUT:
      %       - `s` (struct)
      
      s = struct();
      
      if ( nargin == 1 )
        [s.labels, s.categories] = categorical( obj );
      else
        assert( ischar(flag), 'Flag must be char; was "%s".', class(flag) );
        
        switch ( flag )
          case 'cellstr'
            [s.labels, s.categories] = cellstr( obj );
          case 'categorical'
            [s.labels, s.categories] = categorical( obj );
          otherwise
            opts = { 'cellstr', 'categorical' };
            error( 'Unrecognized flag "%s"; options are:\n\n%s', flag ...
              , strjoin(opts, ' | ') );
        end
      end
    end
    
    function B = saveobj(obj)
      
      %   SAVEOBJ -- Convert object to struct in order to save.
      %
      %     OUT:
      %       - `B` (struct)
      
      B = struct();
      B.categorical = categorical( obj );
      B.categories = getcats( obj );
    end
  end
  
  methods (Access = private)
    
    function inds = checkedfind(obj, tf)
      
      %   CHECKEDFIND -- Find indices of logical vector, checking size.
      %
      %     inds = checkedfind(obj, [true, false]) returns 1, throwing an
      %     error if `obj` is not of size 2xN.
      %
      %     IN:
      %       - `tf` (logical)
      %     OUT:
      %       - `inds` (uint64)
      
      N = size( obj, 1 );
      n = numel( tf );
      
      if ( N ~= n )
        error( 'Logical index must have %d elements; %d were present.', N, n );
      end
      
      inds = uint64( find(tf) );      
    end
    
    function dispfull(obj, desktop_exists, link_str, sz_str)
      
      %   DISPFULL -- Display complete contents.
      
      fprintf( '  %s %s array\n\n', sz_str, link_str );
      try
        disp( categorical(obj) );
      catch err
        %   It's legal to assign the empty character vector ('') as a label
        %   in an fcat object, but not in a categorical array.
        disp( cellstr(obj) );
        warning( ['Object contains labels that are invalid Matlab categorical levels' ...
          , ' (such as ''''). Attempts to convert the object to a categorical' ...
          , ' matrix will fail. Use setdisp(obj, ''short'') to view contents.'] );
      end
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
        %
        % It should appear to the user as though fcat() is a constructor 
        % that takes 0 arguments.
        %
        error( 'Too many input arguments.' );
      end
      
      if ( numel(stack) >= 2 )
        if ( ~strcmp(stack(2).file, 'fcat.m') )
          error( 'Too many input arguments.' );
        end
      end
    end
    
    function obj = from_categorical(C, cats)
      
      %   FROM_CATEGORICAL -- Private utility to convert from categorical
      %     array.
      %
      %     IN:
      %       - `C` (categorical)
      %       - `cats` (cell array of strings)
      %     OUT:
      %       - `obj` (fcat)
      
      nums = double( C );
      
      if ( any(any(isnan(nums))) )
        error( ['Cannot convert from categorical array with <undefined> elements.' ...
          , ' See: `help categorical/isundefined`.'] );
      end
      
      if ( max(max(nums)) >= double(intmax('uint32') - 1) )
        error( ['Cannot convert to fcat from categorical because more than' ...
            , ' `intmax(''uint32'')` categories were present in the array.'] );
      end
      
      labels = categories( C );
      
      try
        obj = fcat( cat_api('from_categorical', cats, labels, uint32(nums)) );
      catch err
        fprintf( ['\n The following error occurred when\n attempting to create' ...
            , ' an fcat object\n from categorical input:\n\n'] );
        throwAsCaller( err );
      end
    end
    
    function obj = from_sp(sp)
      
      %   FROM_SP -- Private utility to convert from SparseLabels object.
      %
      %     IN:
      %       - `sp` (SparseLabels)
      %     OUT:
      %       - `obj` (fcat)
      
      labs = sp.labels;
      inds = sp.indices;
      all_cats = sp.categories;
      unique_cats = unique( all_cats );
      
      if ( numel(labs) >= double(intmax('uint32') - 1) )
        error( ['Cannot convert to fcat from SparseLabels because more than' ...
            , ' `intmax(''uint32'')` labels were present in the object.'] );
      end
      
      mat = zeros( size(inds, 1), numel(unique_cats), 'uint32' );
      
      for i = 1:numel(labs)
        rows = inds(:, i);
        category = all_cats{i};
        col = strcmp( unique_cats, category );
        mat(rows, col) = uint32( i );
      end
      
      obj = fcat( cat_api('from_categorical', unique_cats, labs, mat) );
    end
    
    function obj = from_struct(s)
      
      %   FROM_STRUCT -- Private utility to convert to fcat from struct.
      %
      %     IN:
      %       - `s` (struct)
      %     OUT:
      %       - `obj` (fcat)
      
      assert( all(isfield(s, {'labels', 'categories'})), ['Struct input' ...
        , ' must be a struct with fields ''labels'' and ''categories''.'] );
      
      obj = fcat.from( s.labels, s.categories );
    end
  end
  
  methods (Static = true, Access = public)
    
    function obj = loadobj(B)
      
      %   LOADOBJ -- Load and instantiate fcat.
      %
      %     OUT:
      %       - `obj` (fcat)
      
      obj = fcat.from( B.categorical, B.categories );
    end
    
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
    
    function obj = like(B)
      
      %   LIKE -- Create fcat with the categories and labels of another fcat.
      %
      %     B = fcat.like( A ) returns an fcat object `B` with the same
      %     categories and labels as fcat object `A`, but 0 rows.
      %
      %     See also fcat/with, fcat/from
      %
      %     IN:
      %       - `B` (fcat)
      
      if ( ~isa(B, 'fcat') )
        error( 'Input must be an fcat object; was "%s".', class(B) );
      end
      
      obj = keep( copy(B), [] );
    end
    
    function obj = from(varargin)
      
      %   FROM -- Create fcat from compatible source.
      %
      %     f = fcat.from( c ) constructs an fcat object from the cell
      %     matrix of strings or categorical matrix `c`. Entries of `c`
      %     must be unique across columns. For categorical matrices, no
      %     elements can be <undefined>. Category names are chosen
      %     automatically using the pattern 'cat%d', where %d is the i-th
      %     column index of `c`.
      %
      %     f = fcat.from( c, cats ) uses the cell array of category names
      %     `cats` to identify columns of `c`.
      %
      %     C = fcat.from( sp ) creates an fcat object from the
      %     SparseLabels or Labels object `sp`.
      %
      %     EX //
      %
      %     f = fcat.from({'NY', 'NYC'; 'CA', 'LA'}, {'State', 'City'})
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
          
        elseif ( isa(arr, 'SparseLabels') )
          obj = fcat.from_sp( arr );
          return;
          
        elseif ( isa(arr, 'Labels') )
          cats = arr.fields;
          arr = arr.labels;
          
        elseif ( isstruct(arr) )
          try
            obj = fcat.from_struct( arr );
          catch err
            throw( err );
          end
          return;
          
        else
          error( 'Cannot convert to fcat from objects of type "%s"', class(arr) );
        end
      else
        cats = varargin{2};
      end
      
      if ( ischar(cats) || isa(cats, 'categorical') )
        cats = cellstr( cats );
      else
        assert( iscellstr(cats), ['Categories must be cell array of strings,' ...
          , ' char, or categorical; was "%s".'], class(cats) );
      end

      if ( numel(unique(cats)) ~= numel(cats) )
        error( 'Categories cannot contain duplicates.' );
      end

      if ( numel(cats) ~= size(arr, 2) )
        if ( numel(cats) == 0 && size(arr, 1) == 0 )
          %
          %   no categories and empty label matrix
          %
          obj = fcat();
          return;
        end
        error( 'Supply one category for each column of the labels matrix.' );
      end

      if ( ~ismatrix(arr) )
        error( 'Input cannot have more than 2 dimensions.' );
      end

      if ( isa(arr, 'categorical') )
        obj = fcat.from_categorical( arr, cats );
        return;
      end

      if ( iscellstr(arr) )
        obj = fcat();
        try
          requirecat( obj, cats );
          setcats( obj, cats, arr );
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
    
    function obj = create(varargin)
      
      %   CREATE -- Create fcat with categories set to labels.
      %
      %     obj = fcat.create( 'cat1', 'lab1', 'cat2', 'lab2' )
      %     creates a 1x2 fcat object with categories 'cat1' and 'cat2',
      %     whose labels are 'lab1' and 'lab2', respectively.
      %
      %     obj = fcat.create( 'cat1', 'lab1', 'cat2', {'lab2', 'lab3'} );
      %     creates a 2x2 fcat object with categories 'cat1' and 'cat2'.
      %     Scalar scategories are expanded to match the size of non-scalar
      %     categories.
      %
      %     See also fcat/fcat
      %
      %     IN:
      %       - `varargin` (cell array of strings)
      %     OUT:
      %       - `obj` (fcat)
      
      n = numel( varargin );
      
      try
        assert( mod(n, 2) == 0, '(category, label) pairs are incomplete.' );
        
        cats = varargin(1:2:n);
        labs = varargin(2:2:n);
        
        cellfun( @(x) assert(ischar(x), 'Category names must be char.'), cats );
        
        assert( numel(unique(cats)) == numel(cats), 'Category names must be unique.' );
        
        labs = cellfun( @ensure_cell, labs, 'un', false );
        labs = cellfun( @(x) x(:), labs, 'un', false );
        
        cellfun( @(x) assert(iscellstr(x), 'Labels must be cellstr or char.'), labs );
        
        ns = cellfun( @numel, labs );
        un_ns = unique( ns );
        
        if ( numel(un_ns) > 1 )
          assert( numel(un_ns) == 2 && any(un_ns) == 1 && all(un_ns > 0) ...
            , 'Labels must either match in number, or be scalar, and cannot be empty.' );
        end
        
        non_scalar_ind = ns > 1;
        
        ns_cats = cats( non_scalar_ind );
        ns_labs = labs( non_scalar_ind );
        
        sc_cats = cats( ~non_scalar_ind );
        sc_labs = labs( ~non_scalar_ind );
        
        obj = fcat();
        
        %   process non-scalar categories first, to allow assignment from
        %   empty
        for i = 1:numel(ns_cats)
          addcat( obj, ns_cats{i} );
          setcat( obj, ns_cats{i}, ns_labs{i} );
        end
        
        %   now process scalar categories
        for i = 1:numel(sc_cats)
          addcat( obj, sc_cats{i} );
          setcat( obj, sc_cats{i}, sc_labs{i}{1} );
        end
        
      catch err
        throw( err );
      end
      
      function val = ensure_cell(val)
        if ( ~iscell(val) ), val = { val }; end
      end
    end
    
    function fs = empties(varargin)
      
      %   EMPTIES -- Create cell array of empty fcat objects.
      %
      %     fs = fcat.empties( 1, 2 ) creates a 1x2 cell array of empty
      %     fcat objects.
      %
      %     fs = fcat.empties( [1, 2] ) does the same.
      %
      %     fs = fcat.empties( M, N, P, ... ) or 
      %     fcat.empties( [M, N, P, ...] ) creates an MxNxP... cell array
      %     of empty fcat objects.
      %
      %     IN:
      %       - `sz` (double)
      %     OUT:
      %       - `fs` (cell array of fcat)
      
      %   leverage varargin input handling of cell function
      fs = cell( varargin{:} );
      n = numel( fs );
      
      for i = 1:n
        fs{i} = fcat();
      end
    end
    
    function f = example(varargin)
      
      %   EXAMPLE -- Get example fcat object or data.
      %
      %     fcat.example() returns a small fcat object.
      %     fcat.example( 'small' ) does the same.
      %     fcat.example( 'large' ) returns a large fcat object.
      %
      %     fcat.example( 'smalldata' ) returns a small vector of data.
      %     fcat.example( 'largedata' ) returns a large vector of data.
      %
      %     See also fcat/test, fcat/from, fcat/with
      %
      %     IN:
      %       - `kind` (char) |OPTIONAL|
      %     OUT:
      %       - `f` (fcat, double)
      
      try
        f = cat_getexample( varargin{:} );
      catch err
        throwAsCaller( err );
      end
    end
    
    function test()
      
      %   TEST -- Run all tests.
      %
      %     See also fcat/build, fcat/fcat
      
      cat_testall();      
    end
    
    function build()
      
      %   BUILD -- Build cat_api.
      %
      %     See also fcat/buildconfig
      
      cat_buildall();      
    end
    
    function addpath()
      
      %   ADDPATH -- Add all dependencies to Matlab search path.
      %
      %     See also fcat/apiroot
      
      addpath( genpath(fcat.apiroot()) );
    end
    
    function r = apiroot()
      
      %   APIROOT -- Get the path to the fcat Matlab api directory.
      %
      %     See also fcat/buildconfig, fcat/fcat
      %
      %     OUT:
      %       - `r` (char)
      
      conf = fcat.buildconfig();
      r = conf.apiroot;
    end
    
    function conf = buildconfig()
      
      %   BUILDCONFIG -- Get config options with which the cat_api was built.
      %
      %     See also fcat/fcat
      %
      %     OUT:
      %       - `conf` (struct)
      
      conf = cat_buildconfig();      
    end
    
    function T = table(T, rowc, colc)
      
      %   TABLE -- Convert matrix to table, with row and column labels.
      %
      %     tbl = fcat.table( T, rowc, colc ) constructs a table `tbl`
      %     from the matrix `T` and row and column labels `rowc` and 
      %     `colc`. `rowc` and `colc` can be fcat objects or cell arrays of 
      %     strings.
      %
      %     If `rowc` is an fcat object, it must have the same number of
      %     rows as `T` has rows; if `colc` is an fcat object, it must have
      %     the same number of rows as `T` as cols. In this case, each row
      %     of `rowc` identifies a row of `T`; each row of `colc`
      %     identifies a column of `T`.
      %
      %     If `rowc` is a cell array of strings, it is of size MxN, where 
      %     N is equal to the number of rows of `T`. If `colc` is a
      %     cell array of strings, it is of size PxQ, where Q is equal to
      %     the number of columns of `T`.
      %
      %     EX //
      %
      %     labs = fcat.example();
      %     dat = fcat.example( 'smalldata' );
      %   
      %     [t, rc] = tabular( labs, 'monkey', 'dose' )
      %
      %     d = cellfun( @(x) mean(dat(x)), t );
      %
      %     fcat.table( d, rc{:} )
      %
      %     See also fcat/tabular
      %
      %     IN:
      %       - `T` (/any/)
      %       - `rowc` (fcat, cell array of strings)
      %       - `colc` (fcat, cell array of strings)
      
      import matlab.lang.makeValidName;
      
      try
        if ( isa(rowc, 'fcat') ), rowc = cellstr( rowc )'; end
        if ( isa(colc, 'fcat') ), colc = cellstr( colc )'; end
        
        validate( T, rowc, colc );
        
        pattern = ' | ';
        
        rlabs = fcat.strjoin( rowc, [], pattern );
        clabs = fcat.strjoin( colc, [], pattern );
        clabs = cellfun( @(x) makeValidName(fcat.trim(x)), clabs, 'un', false );
        
        inputs = { 'RowNames', rlabs, 'VariableNames', clabs };

        if ( iscell(T) )
          T = cell2table( T, inputs{:} );
        elseif ( isnumeric(T) )
          T = array2table( T, inputs{:} );
        else
          T = arrayfun( @(x) {x}, T );
          T = cell2table( T, inputs{:} );
        end
      catch err
        throw( err );
      end
      
      function validate(T, rowc, colc)
        n1 = size( rowc, 2 );
        n2 = size( colc, 2 );
        
        msg = '%s combinations must have %d elements; %d were present.';
        
        [row, col] = size( T );
        
        assert( n1 == row, msg, 'Row', row, n1 );
        assert( n2 == col, msg, 'Column', col, n2 );        
      end
    end
    
    function str = trim(str)
      
      %   TRIM -- Remove select characters and whitespace from string.
      %
      %     s = fcat.trim( '<drugs>. ' ) returns 'drugs', stripping '<',
      %     '>', ' ', and '.' from `s`.
      %
      %     s = fcat.trim( C ) trims all strings in the cell array of
      %     strings `C`, returning a cell array of the same size as `C`.
      %
      %     See also fcat.strjoin, fcat/joincat
      %
      %     IN:
      %       - `str` (cell array of strings, char)
      %     OUT:
      %       - `str` (cell array of strings, char)
      
      if ( iscell(str) )
        str = cellfun( @trim_func, str, 'un', false );
      else
        str = trim_func( str );
      end
      
      function str = trim_func(str)
        str = regexprep( str, '[<>. ]', '' );
      end
    end
    
    function strs = strjoin(C, dim, pattern)
      
      %   STRJOIN -- Join array of strings, across dimension.
      %
      %     strs = ... strjoin( C ) produces a 1xN cell array of strings
      %     `strs`, whose elements are the elements of `C` joined along
      %     columns.
      %
      %     strs = ... strjoin( ..., DIM ) operates along dimension `DIM`.
      %
      %     strs = ... strjoin( ..., PATTERN ) uses `PATTERN` to join
      %     elements of `C`.
      %
      %     See also fcat/combs
      %
      %     IN:
      %       - `C` (cell array of strings)
      %       - `dim` (double)
      %       - `pattern` (char) |OPTIONAL|
      
      if ( nargin < 3 ), pattern = '_'; end
      if ( nargin < 2 || isempty(dim) ), dim = 2; end
      
      N = size( C, dim );
      n = ndims( C );
      
      indices = repmat( {':'}, 1, n );
      
      sizes = ones( 1, n );
      sizes( dim ) = N;
      
      strs = cell( sizes );
      
      for i = 1:N
        indices{dim} = i;
        joined = strjoin( C(indices{:}), pattern );
        strs(indices{:}) = { joined };
      end      
    end
    
    function ns = parse(strs, removing)
      
      %   PARSE -- Parse number(s) from string(s).
      %
      %     ns = fcat.parse( strs ) is the same as str2double( strs );
      %     ns = fcat.parse( strs, remove ) first removes the char vector
      %     `remove` from `strs` before performing the conversion.
      %
      %     `strs` can be a char vector or cell array of strings.
      %
      %     See also fcat/strjoin, fcat/joincat
      %
      %     IN:
      %       - `strs` (char, cell array of strings)
      %       - `removing` (char) |OPTIONAL|
      %     OUT:
      %       - `ns` (double)
      
      if ( nargin < 2 ), removing = ''; end
      if ( ~isempty(removing) ), strs = regexprep( strs, removing, '' ); end
      ns = str2double( strs );            
    end
  end
end