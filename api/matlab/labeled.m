classdef labeled < handle
  
  properties (SetAccess = private, GetAccess = public)
    data;
  end
  
  properties (Access = private)
    labels;
    datatype;
  end
  
  methods (Access = public)
    
    function obj = labeled(data, labels)
      
      %   LABELED -- Create a labeled object.
      %
      %     IN:
      %       - `data` (/any/)
      %       - `labels` (fcat)
      
      if ( nargin == 0 )
        data = [];
        labels = fcat();
      end
      
      setall( obj, data, labels );
    end
    
    function tf = eq(obj, B)
      
      %   EQ -- True if two labeled objects have equal contents.
      %
      %     NaN values in data are compared as equal.
      %
      %     See also labeled/labeled
      %
      %     IN:
      %       - `B` (/T/)
      %     OUT:
      %       - `tf` (logical)
      
      tf = isa( obj, 'labeled' ) && isa( B, 'labeled' ) && ...
        isequaln( obj.data, B.data ) && obj.labels == B.labels;
    end
    
    function tf = ne(obj, B)
      
      %   NE -- False if two labeled objects have equal contents.
      %
      %     See also labeled/eq
      %
      %     IN:
      %       - `B` (/T/)
      %     OUT:
      %       - `tf` (logical)
      
      tf = ~eq( obj, B );
    end
    
    function obj = eachindex(obj, categories, func)
      
      %   EACHINDEX -- Apply function to data, with indices of subsets.
      %
      %     eachindex( obj, categories, func ) calls `func` with inputs 
      %     `obj.data` and a cell array of indices `I` whose elements 
      %     identify unique combinations of labels in `categories`.
      %
      %     IN:
      %       - `categories` (cell array of strings, char)
      %       - `func` (function_handle)
      
      if ( ~isa(obj, 'labeled') )
        error( 'First input must be a labeled; was "%s".', class(obj) );
      end
      
      if ( nargin ~= 3 )
        narginchk( 2, 2 );
        func = categories;
        categories = getcats( obj.labels );
      end
      
      if ( ~isa(func, 'function_handle') )
        error( 'Third input must be a function_handle; was "%s".', class(func) );
      end
      
      [new_labs, I] = keepeach( obj.labels, categories );
      new_data = func( obj.data, I );
      
      sz_msg = [ 'The output of a function called with eachindex or each' ...
        , ' must have a single row for each label-combination.' ];
      
      setall( obj, new_data, new_labs, sz_msg );
    end
    
    function obj = each(obj, cats, func, uniform)
      
      %   EACH -- Apply function to subsets of rows of data.
      %
      %     each( obj, categories, func ) calls `func` with a single input
      %     for each combination of labels in `categories`. The input to
      %     `func` is the subset of rows of `obj.data` associated with a
      %     given label combination. The output of `func` must be uniform;
      %     i.e., calls to `func` must yield arrays of the same class, 
      %     with 1 row, and with matching sizes along the remaining 
      %     dimensions.
      %
      %     each( ..., isuniform ) specifies whether the output of `func`
      %     is uniform. If `isuniform` is false, data in the object are an
      %     Mx1 cell array.
      %
      %     See also labeled/eachobj, labeled/eachindex
      %
      %     IN:
      %       - `categories` (cell array of strings, char)
      %       - `func` (function_handle)
      %       - `uniform` (logical) |OPTIONAL|
      
      if ( nargin < 4 )
        uniform = true;
      end
      
      if ( ~isa(func, 'function_handle') )
        error( 'Third input must be a function_handle; was "%s".', class(func) );
      end
      
      eachindex( obj, cats, @(x, I) rowop(x, I, func, uniform) );
    end
    
    function [out, I, C] = eachobj(obj, cats, func, uniform)
      
      %   EACHOBJ -- Apply function to subsets of labeled object.
      %
      %     B = each( obj, categories, func ) calls `func` with a single 
      %     input for each combination of labels in `categories`. The input 
      %     to `func` is a labeled object whose rows of data and labels are
      %     associated with a given label combination. The output of `func`
      %     must also be a labeled object.
      %
      %     B = each( ..., isuniform ) specifies whether the output of 
      %     `func` is uniform. The output of `func` is uniform if each call 
      %     to `func` yields a labeled object with append-able data and 
      %     labels. If `isuniform` is false, B is an Mx1 cell array, and
      %     the original object is unmodified.
      %
      %     [B, I] = ... also returns the cell array of uint64 indices `I`
      %     used to select each subset of `obj`.
      %
      %     [B, I, C] = ... also returns the cell array of label
      %     combinations associated with each index in `I`.
      %
      %     See also labeled/each, labeled/eachindex, labeled/findall
      %
      %     IN:
      %       - `categories` (cell array of strings, char)
      %       - `func` (function_handle)
      %       - `uniform` (logical) |OPTIONAL|
      %     OUT:
      %       - `out` (labeled, cell)
      %       - `I` (cell array of uint64)
      %       - `C` (cell array of strings)
      
      if ( nargin < 4 )
        uniform = true;
      end
      
      out = obj;
      
      if ( nargin < 3 )
        I = findall( obj.labels, cats );
      else
        [I, C] = findall( obj.labels, cats );
      end
      
      n_inds = numel( I );
      
      if ( n_inds == 0 && uniform )
        keep( obj, [] );
        return;
      end
      
      if ( ~uniform )
        out = cell( n_inds, 1 );
        
        for i = 1:n_inds
          out{i} = func( keep(copy(obj), I{i}) );
        end
        
        return;        
      end
      
      for i = 1:n_inds        
        res = func( keep(copy(obj), I{i}) );
        
        if ( ~isa(res, 'labeled') )
          error( ['The output of a function passed to eachobj must be' ...
            , ' a labeled object; was "%s".'], class(res) );
        end
        
        if ( i == 1 )
          new_labs = fcat.like( res.labels );
          colons = repmat( {':'}, 1, ndims(res.data)-1 );
          new_data = res.data( [], colons{:} );
        else
          append( new_labs, res.labels );
          new_data = [ new_data; res.data ];
        end
      end
      
      setall( obj, new_data, new_labs );
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
            
            current_sz = size( obj, 1 );
            
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
                if ( current_sz > 0 )
                  setcat( obj.labels, sub, values );
                else
                  error( 'Index exceeds matrix dimensions.' );
                end
              end
            elseif ( numel(subs) == 2 )
              is_colon_m = strcmp( subs{1}, ':' );
              is_colon_n = strcmp( subs{2}, ':' );
              
              if ( is_colon_m )
                if ( is_colon_n )
                  %
                  % x(:, :) = values
                  %
                  if ( current_sz > 0 )
                    setcats( obj.labels, getcats(obj.labels), values );
                  else
                    error( 'Index exceeds matrix dimensions.' );
                  end
                elseif ( ischar(subs{2}) )
                  %
                  % x(:, 'hi') = 'sup';
                  % 
                  if ( current_sz > 0 )
                    setcat( obj.labels, subs{2}, values );
                  else
                    error( 'Index exceeds matrix dimensions.' );
                  end
                else
                  %
                  % x(:, 1) = 'val'
                  %
                  nums = subs{2};
                  cats = getcats( obj.labels );
                  msg = 'Category index must be numeric or a colon.';
                  if ( ~is_colon_n )
                    assert( isnumeric(nums), msg );
                    c = cats(nums);
                  else
                    c = cats;
                  end
                  if ( current_sz > 0 )
                    setcats( obj.labels, c, values );
                  else
                    error( 'Index exceeds matrix dimensions.' );
                  end
                end
              else  %  not colon m
                if ( ischar(subs{2}) && ~is_colon_n )
                  %
                  % x(1:10, 'hi') = 'sup';
                  % 
                  if ( current_sz > 0 )
                    setcat( obj.labels, subs{2}, values, subs{1} );
                  else
                    error( 'Index exceeds matrix dimensions.' );
                  end
                else
                  %
                  % x(1:2, 1) = 'sup' | x(1:2, 2:4) = { .. } | 
                  % x(1:2, :) = 'hi'
                  %
                  nums = subs{2};
                  msg = 'Category index must be numeric or a colon.';
                  if ( ~is_colon_n )
                    assert( isnumeric(nums), msg );
                    cats = getcats( obj.labels );
                    c = cats(nums);
                  else
                    c = getcats( obj.labels );
                  end
                  %
                  % do the assignment
                  %
                  if ( current_sz > 0 )
                    setcats( obj.labels, c, values, subs{1} );
                  else
                    error( 'Index exceeds matrix dimensions.' );
                  end
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
                  varargout{1} = incat( obj.labels, category_or_inds );
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
                    varargout{1} = fullcat( obj.labels, index_or_colon );
                    return;
                  else
                    varargout{1} = partcat( obj.labels, index_or_colon, category_or_inds );
                    return;
                  end
                end
                %
                % obj(1, 1) | obj(1, :) | obj(:, 1) | obj(:, :)
                %
                cats = getcats( obj.labels );
                
                if ( ~strcmp(index_or_colon, ':') )
                  cats = cats(index_or_colon);
                end
                
                all_rows = strcmp( category_or_inds, ':' );
                
                if ( all_rows )
                  out = fullcat( obj.labels, cats );
                else
                  out = partcat( obj.labels, cats, category_or_inds );
                end
                
                varargout{1} = out;
                return;
              end
              
              if ( ischar(category_or_inds) )
                error( 'Specify a category as a column subscript.' );
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
            %
            % y = x.data;
            %
            if ( strcmp(subs, 'data') )
              varargout{1} = getdata( obj );
            else
              error( 'No properties or methods matched "%s".', subs );
            end
          otherwise
            error( 'Referencing with "%s" is not supported.', type );
        end
        
        if ( ~isempty(s) )
          n_out = nargout();
          if ( n_out == 0 )
            varargout{1} = subsref( varargout{1}, s );
          else
            [varargout{1:n_out}] = subsref( varargout{1}, s );
          end
        end
      catch err
        throwAsCaller( err );
      end
    end
    
    function n = numArgumentsFromSubscript(obj, a, b)      
      n = 1;
    end
    
    function n = nlabs(obj)
      
      %   NLABS -- Get the current number of labels.
      %
      %     See also fcat/size, fcat/ncats, fcat/numel
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = nlabs( obj.labels );      
    end
    
    function n = ncats(obj)
      
      %   NCATS -- Get the current number of categories.
      %
      %     See also fcat/size, fcat/labs, fcat/numel
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = ncats( obj.labels );  
    end
    
    function obj = only(obj, labels)
      
      %   ONLY -- Retain rows associated with labels.
      %
      %     See also fcat/keep, fcat/find
      
      keep( obj, find(obj, labels) );
    end
    
    function obj = keep(obj, at_indices)
      
      %   KEEP -- Retain rows at indices.
      %
      %     See also fcat/keep
      %
      %     IN:
      %       - `at_indices` (uint64, double)
      
      colons = repmat( {':'}, 1, ndims(obj.data)-1 );
      obj.data = obj.data( at_indices, colons{:} );
      keep( obj.labels, at_indices );
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
      
      [~, C] = findall( obj.labels, categories );
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
        [I, C] = findall( obj.labels, categories );
      else
        I = findall( obj.labels, categories );
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
      
      I = find( obj.labels, labels );
    end
    
    function C = getcats(obj)
     
      %   GETCATS -- Get category names.
      %
      %     See also fcat/getlabs, fcat/fcat
      %
      %     OUT:
      %       - `C` (cell array of strings)
      
      C = getcats( obj.labels );
    end
    
    function L = getlabs(obj)
      
      %   GETLABS -- Get label names.
      %
      %     See also fcat/getcats
      %
      %     OUT:
      %       - `L` (cell array of strings)
      
      L = getlabs( obj.labels ); 
    end
    
    function n = numel(varargin)
      
      %   SIZE -- Get the number of rows in the object.
      %
      %     See also labeled/size
      %
      %     OUT:
      %       - `n` (double)
      
      n = numel( varargin{1}.data );
    end
    
    function sz = size(obj, varargin)
      
      %   SIZE -- Get the number of rows in the object.
      %
      %     See also labeled/numel
      %
      %     IN:
      %       - `dimension` |OPTIONAL| (numeric)
      %     OUT:
      %       - `sz` (double)
      
      sz = size( obj.data, varargin{:} );
    end
    
    function s = end(obj, ind, N)
      
      %   END -- Get the final index in a given dimension.
      %
      %     IN:
      %       - `ind` (double)
      %       - `N` (double)
      %     OUT:
      %       - `s` (double)
      
      s = size( obj.labels, ind );
    end
    
    function data = getdata(obj)
      
      %   GETDATA -- Get data.
      %
      %     OUT:
      %       - `data` (/any/)
      
      data = obj.data;
    end
    
    function labs = getlabels(obj)
      
      %   GETLABELS -- Get labels.
      %
      %     See also labeled/labeled, labeled/setlabels
      %
      %     OUT:
      %       - `labels` (fcat)
      
      labs = copy( obj.labels );
    end
    
    function tf = haslab(obj, labels)
      
      %   HASLAB -- True if the label(s) exists.
      %
      %     IN:
      %       - `labels` (char, cell array of strings)
      %     OUT:
      %       - `tf` (logical)
      
      tf = haslab( obj.labels, labels );
    end
    
    function tf = hascat(obj, categories)
      
      %   HASLAB -- True if the category(ies) exists.
      %
      %     IN:
      %       - `categories` (char, cell array of strings)
      %     OUT:
      %       - `tf` (logical)
      
      tf = hascat( obj.labels, categories );   
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
      
      C = fullcat( obj.labels, categories );
    end
    
    function C = partcat(obj, categories, indices)
      
      %   PARTCAT -- Get part of a category or categories.
      %
      %     IN:
      %       - `categories` (char)
      %       - `indices` (uint64)
      
      C = partcat( obj.labels, categories, indices );
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
      
      C = incat( obj.labels, category );
    end
    
    function obj = requirecat(obj, category)
      
      %   REQUIRECAT -- Add category if it does not exist.
      %
      %     See also fcat/findall
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      requirecat( obj.labels, category );
    end
    
    function obj = addcat(obj, category)
      
      %   ADDCAT -- Add category.
      %
      %     See also fcat/findall
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      addcat( obj.labels, category );
    end
    
    function obj = rmcat(obj, category)
      
      %   RMCAT -- Remove category(ies).
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      rmcat( obj.labels, category );
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
      
      collapsecat( obj.labels, category );
    end
    
    function obj = one(obj)
      
      %   ONE -- Collapse all categories, and retain a single row.
      
      if ( numel(obj) == 0 )
        return;
      end
      
      setall( obj, NaN, one(obj.labels) );
    end
    
    function obj = setdata(obj, data)
      
      %   SETDATA -- Assign data.
      %
      %     See also labeled/labeled, labeled/setlabels
      %
      %     IN:
      %       - `data` (/any/)
      
      if ( size(data, 1) ~= size(obj.labels, 1) )
        error( ['Data must have the same number of rows as labels.' ...
          , ' Current number of rows is %d.'], size(obj, 1) );
      end
      
      obj.data = data;
      obj.datatype = class( data );
    end
    
    function obj = setlabels(obj, labels)
      
      %   SETLABELS -- Assign labels.
      %
      %     See also labeled/labeled, labeled/setdata
      %
      %     IN:
      %       - `data` (/any/)
      
      if ( ~isa(labels, 'fcat') )
        error( 'Labels must be "fcat"; were "%s".', class(labels) );
      end
      
      labs_sz = size( labels, 1 );
      data_sz = size( obj.data, 1 );
      
      labs = copy( labels );
      
      if ( labs_sz ~= data_sz )
        if ( labs_sz == 1 && data_sz > 1 )
          repeat( labs, data_sz-1 );
        else
          error( ['Labels must have the same number of rows as data.' ...
            , ' Current number of rows is %d.'], size(obj, 1) );
        end
      end
      
      obj.labels = copy( labels );
    end
    
    function obj = setall(obj, data, labels, sz_msg)
      
      %   SETALL -- Assign data and labels.
      %
      %     See also labeled/labeled, labeled/setdata
      %
      %     IN:
      %       - `data` (/any/)
      %       - `labels` (fcat)
      
      if ( nargin < 4 )
        sz_msg = 'Data must have the same number of rows as labels.';
      end
      
      dat_sz = size( data, 1 );
      lab_sz = size( labels, 1 );
      
      if ( ~isa(labels, 'fcat') )
        error( 'Labels must be "fcat"; were "%s".', class(labels) );
      end
      
      labs = copy( labels );
      
      %   expand labels to match data.
      if ( dat_sz ~= lab_sz )
        if ( lab_sz == 1 && dat_sz > 1 )
          labs = copy( labels );
          repeat( labs, dat_sz - 1 );
        else
          error( sz_msg );
        end
      end
      
      obj.data = data;
      obj.labels = labs;
      obj.datatype = class( data );
    end
    
    function obj = append(obj, B)
      
      %   APPEND -- Append another fcat object.
      %
      %     See also fcat/fcat
      %
      %     IN:
      %       - `B` (fcat)
      
      if ( ~isa(obj, 'labeled') )
        error( 'Cannot append objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'labeled') )
        error( 'Cannot append objects of class "%s".', class(B) );
      end
      
      append( obj.labels, B.labels );
      
      obj.data = [obj.data; B.data];
    end
    
    function obj = assign(obj, B, to_indices, from_indices)
      
      %   ASSIGN -- Append contents of other labeled object at indices.
      %
      %     See also labeled/labeled
      %
      %     IN:
      %       - `B` (labeled)
      %       - `to_indices` (uint64)
      %       - `from_indices` (uint64)      
      
      if ( ~isa(obj, 'labeled') )
        error( 'Cannot assign objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'labeled') )
        error( 'Cannot assign  objects of class "%s".', class(B) );
      end
      
      data_copy = obj.data;
      
      colons = repmat( {':'}, 1, ndims(data_copy)-1 );
      
      if ( nargin == 3 )
        data_copy(to_indices, colons{:}) = B.data;
      else
        data_copy(to_indices, colons{:}) = B.data(from_indices, colons{:});
      end
      
      if ( nargin == 3 )
        assign( obj.labels, B.labels, to_indices );
      else
        assign( obj.labels, B.labels, to_indices, from_indices );
      end
      
      obj.data = data_copy;
    end
    
    function obj = replace(obj, from, with)
      
      %   REPLACE -- Replace labels with label.
      %
      %     replace( obj, 'label1', 'label2' ); replaces occurrences of
      %     'label1' with 'label2'. If 'label2' exists in `obj`, it must be
      %     in the same category as 'label1'.
      %
      %     replace( obj, {'lab1', 'lab2'}, 'lab3' ); works as above, but
      %     for multiple labels.
      %
      %     IN:
      %       - `from` (cell array of strings, char)
      %       - `with` (char)
      
      replace( obj.labels, from, with );
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
      
      [~, n] = prune( obj.labels );
    end
    
    function obj = vertcat(obj, varargin)
      
      %   VERTCAT -- Append other labeled objects.
      %
      %     See also fcat/append
      %
      %     IN:
      %       - `B` (labeled)
      
      for i = 1:numel(varargin)
        append( obj, varargin{i} );
      end
    end
    
    function B = ctranspose(obj)
      
      %   CTRANSPOSE -- Overloaded operator copy.
      %
      %     B = A'; is syntactic sugar for B = copy( A );
      %
      %     See also labeled/copy
      %
      %     OUT:
      %       - `B` (labeled)
      
      B = copy( obj );
    end
    
    function B = copy(obj)
      
      %   COPY -- Create a copy of the object.
      %
      %     OUT:
      %       - `obj` (labeled)
      
      B = labeled( obj.data, obj.labels );
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
      
      setdisp( obj.labels, mode );
    end
    
    function disp(obj)
      
      %   DISP -- Pretty-print the object's contents.
      
      disp( obj.labels, class(obj) );
    end
    
    function delete(obj)
      
      %   DELETE -- Delete object and free memory.
      %
      %     See also fcat/fcat
      %
      %     Calling `clear obj` also deletes the object.
      
      delete( obj.labels );
    end
  end
  
  methods (Static = true)
    
    function obj = from(convertible)
      
      %   FROM -- Convert to labeled from compatible source.
      %
      %     IN:
      %       - `convertible`
      
      if ( isa(convertible, 'Container') )
        obj = labeled( convertible.data, fcat.from(convertible.labels) );
        return;
      end
      
      error( 'Cannot convert to labeled from object of class "%s".' ...
        , class(convertible) );
    end
    
    function obj = like(other)
      
      %   LIKE -- Create empty object with data and labels like those of
      %     another object.
      %
      %     IN:
      %       - `other` (labeled)
      
      if ( ~isa(other, 'labeled') )
        error( 'Input must be a labeled object; was "%s".', class(other) );
      end
      
      obj = keep( copy(other), [] );
    end
  end
end