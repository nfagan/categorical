classdef fcat < handle
    
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
      %     columns. In this way, each "column" of an FCAT object
      %     constitutes a category (or dimension) with an arbitrary number
      %     of levels (or labels). Rows of observations can then be 
      %     identified by a given combination of labels across all 
      %     categories.
      %
      %     See also fcat/findall, fcat/from, fcat/subsref, categorical
      
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
      obj.displaymode = 'short';
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
      
      %   SIZE -- Get the number of rows in the object.
      %
      %     See also fcat/size
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = size( varargin{1}, 1 );
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
      %     obj('category', 1:10) = 'label'; sets the first 10 elements,
      %     only.
      %
      %     obj('category', 2:3) = { 'lab1', 'lab2' } sets the second and
      %     third elements to 'lab1' and 'lab2', respectively.
      %
      %     See also fcat/subsref, fcat/fcat
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
              %
              % x('hi') = 'sup';
              %
              setcat( obj, subs{1}, values );
            elseif ( numel(subs) == 2 )
              if ( strcmp(subs{2}, ':') )
                %
                % x('hi', :) = 'sup';
              	% 
                setcat( obj, subs{1}, values );
              else
                %
                % x('hi', 1:10) = 'sup';
              	% 
                setcat( obj, subs{1}, values, subs{2} );
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
      %     c = obj('category', 1:10) returns the first 10 labels in
      %     'category', in order, throwing an error if size is less than
      %     10.
      %
      %     c = obj('category', [1; 1; 1]) works as above, but returns a
      %     3x1 array of the duplicated first label in 'category'.
      %
      %     c = obj('category', :) returns the full 'category'.
      %
      %     c = obj(1:10) returns a copied fcat object whose elements are
      %     the first 10 rows of `obj`.
      %
      %     c = obj(:) creates a copy of `obj`.
      %
      %     See also fcat/subsasgn, fcat/fcat
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
              
              if ( isnumeric(category_or_inds) || strcmp(category_or_inds, ':') )
                %
                % obj(1, 1) | obj(1, :) | obj(:, 1) | obj(:, :)
                %
                cats = getcats( obj );
                
                if ( ~strcmp(index_or_colon, ':') )
                  cats = cats(index_or_colon);
                end
                
                if ( strcmp(category_or_inds, ':') )
                  all_rows = true;
                  out = cell( numel(obj), numel(cats) );
                else
                  all_rows = false;
                  out = cell( numel(category_or_inds), numel(cats) );
                end
                
                for i = 1:numel(cats)
                  if ( all_rows )
                    out(:, i) = fullcat( obj, cats{i} );
                  else
                    out(:, i) = partcat( obj, cats{i}, category_or_inds );
                  end
                end
                
                varargout{1} = out;
                return;
              end

              if ( strcmp(index_or_colon, ':') )
                varargout{1} = fullcat( obj, category_or_inds );
              else
                varargout{1} = partcat( obj, category_or_inds, index_or_colon );
              end
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
    
    function C = combs(obj, categories)
      
      %   COMBS -- Get present combinations of labels in categories.
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
      
      if ( ischar(categories) )
        C = cat_api( 'full_cat', obj.id, categories );
        return;
      end
      
      if ( ~iscell(categories) )
        error( 'Categories must be a cell array of strings, or char.' );
      end
      
      n_cats = numel( categories );
      N = numel( obj );
      C = cell( N, n_cats );
      
      for i = 1:n_cats
        C(:, i) = cat_api( 'full_cat', obj.id, categories{i} );
      end
    end
    
    function C = partcat(obj, category, indices)
      
      %   PARTCAT -- Get part of a category.
      %
      %     IN:
      %       - `category` (char)
      %       - `indices` (uint64)
      
      C = cat_api( 'partial_cat', obj.id, category, uint64(indices) );      
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
      %     contents of the object, and is the default.
      %
      %     setdisp( obj, 'full' ) displays the full contents of `obj` as
      %     if it were a cell array of strings.
      %
      %     See also fcat/cellstr, fcat/categorical
      %
      %     IN:
      %       - `mode` ({'short', 'full'})
      
      modes = { 'short', 'full' };
      if ( ~ischar(mode) || ~any(strcmp(modes, mode)) )
        error( 'Invalid display mode. Options are: \n\n%s', strjoin(modes, ' | ') );
      end
      obj.displaymode = mode;
    end
    
    function disp(obj)
      
      %   DISP -- Pretty-print the object's contents.
      %
      %     See also fcat/fcat, fcat/getcats
      
      desktop_exists = usejava( 'desktop' );
      
      cls = class( obj );
      
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
      
      if ( strcmp(obj.displaymode, 'full') )
        disp( getcats(obj)' );
        disp( '--' );
        disp( cellstr(obj) );
        return;
      end
      
      cats = getcats( obj );
      
      if ( numel(cats) == 0 )
        addtl_str = 'with 0 categories';
      else
        addtl_str = 'with categories:';
      end
      
      max_labs = 5;
      max_cats = 10;
      
      sz = numel( obj );
      
      if ( desktop_exists )
        sz_str = sprintf( '%d×1', sz );
      else
        sz_str = sprintf( '%d-by-1', sz );
      end
      
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
      
      [C, F] = cellstr( obj );
      C = categorical( C );
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
    
    function obj = with(cats)
      
      %   WITH -- Create fcat with categories.
      %
      %     IN:
      %       - `cats` (char, cell array of strings)
      %     OUT:
      %       - `obj` (fcat)
      
      obj = requirecat( fcat(), cats );
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
            , ' a fcat object\n from cellstr or categorical input:\n\n'] );
          throw( err );
        end
        return;
      end

      error( 'Cannot convert to fcat from objects of type "%s"', class(arr) );
    end
  end
end