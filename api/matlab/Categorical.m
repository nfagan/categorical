classdef Categorical < handle
    
  properties (Access = private)
    id;
  end
  
  methods
    
    function obj = Categorical(id)
      
      %   CATEGORICAL -- Create categorical object.
      
      if ( nargin == 0 )
        obj.id = cat_api( 'create' );
      else
        assert( cat_api('is_valid', id), 'Invalid ID given.' );
        obj.id = id;
      end
    end
    
    function n = numel(obj)
      
      %   SIZE -- Get the number of rows in the object.
      %
      %     See also Categorical/size
      %
      %     OUT:
      %       - `n` (uint64)
      
      n = size( obj, 1 );
    end
    
    function tf = isempty(obj)
      
      %   ISEMPTY -- True if the object is of size 0.
      %
      %     OUT:
      %       - `tf` (logical)
      
      tf = numel( obj ) == 0;      
    end
    
    function sz = size(obj, dim)
      
      %   SIZE -- Get the number of rows in the object.
      %
      %     See also Categorical/numel, Categorical/getlabs
      %
      %     IN:
      %       - `dimension` |OPTIONAL| (numeric)
      %     OUT:
      %       - `sz` (uint64)
      
      if ( nargin == 1 )
        if ( isvalid(obj) )
          sz = [ cat_api('size', obj.id), 1 ];
        else
          sz = [ 0, 1 ];
        end
        return;
      end
      
      msg = [ 'Dimension argument must be a positive integer' ...
          , ' scalar within indexing range.' ];
        
      if ( ~isnumeric(dim) || ~isscalar(dim) || dim < 1 )
        error( msg );
      end
      
      if ( dim > 1 )
        sz = 1;
        return;
      end
      
      if ( isvalid(obj) )
        sz = cat_api( 'size', obj.id );
      else
        sz = 0;
      end
    end
    
    function obj = resize(obj, to)
      
      %   RESIZE -- Expand or contract object.
      %
      %     IN:
      %       - `to` (uint64)
      
      cat_api( 'resize', obj.id, uint64(to) );      
    end
    
    function obj = keep(obj, indices)
      
      %   KEEP -- Retain rows at indices.
      %
      %     See also Categorical/Categorical, Categorical/findall
      %
      %     IN:
      %       - `indices` (uint64)
      
      cat_api( 'keep', obj.id, uint64(indices) );     
    end
    
    function obj = only(obj, labels)
      
      %   ONLY -- Retain rows associated with labels.
      %
      %     See also Categorical/keep, Categorical/find
      
      keep( obj, find(obj, labels) );
    end
    
    function C = combs(obj, categories)
      
      %   COMBS -- Get present combinations of labels in categories.
      %
      %     See also Categorical/findall
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
      %     See also Categorical/combs, Categorical/find
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
      %     E.g., if `obj` is a Categorical with labels '0' and '1' in 
      %     category '0', then find( obj, {'0', '1'} ) returns rows 
      %     associated with '0' OR '1'.
      %
      %     But if `obj` is a Categorical with labels '0' and '1' in 
      %     categories '0' and '1', respectively, then 
      %     find( obj, {'0', '1'} ) returns the subset of rows associated 
      %     with '0' AND '1'.
      %
      %     See also Categorical/getlabs, Categorical/getcats
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
      %     See also Categorical/getlabs, Categorical/Categorical
      %
      %     OUT:
      %       - `C` (cell array of strings)
      
      C = cat_api( 'get_cats', obj.id );      
    end
    
    function L = getlabs(obj)
      
      %   GETLABS -- Get label names.
      %
      %     See also Categorical/getcats
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
      %     See also Categorical/setcat
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
    
    function C = incat(obj, category)
      
      %   INCAT -- Get labels in category.
      %
      %     See also Categorical/fullcat
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
      %     See also Categorical/addcat
      %
      %     IN:
      %       - `category` (char, cell array of strings)
      
      cat_api( 'require_cat', obj.id, category );
    end
    
    function obj = setcat(obj, category, to, at_indices)
      
      %   SETCATEGORY -- Assign labels to category.
      %
      %     A) setcat( obj, 'hi', {'hello', 'hello', 'hello'} ) assigns
      %     {'hello', 'hello', 'hello'} to category 'hi'.
      %
      %     If the object was empty beforehand, it will become of size 3x1,
      %     and additional categories will be filled with the collapsed
      %     expression for each category. Otherwise, it must be of size
      %     3x1.
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
      %     See also Categorical/requirecat
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
    
    function obj = append(obj, B)
      
      %   APPEND -- Append another Categorical object.
      %
      %     See also Categorical/Categorical
      %
      %     IN:
      %       - `B` (Categorical)
      
      if ( ~isa(obj, 'Categorical') )
        error( 'Cannot append objects of class "%s".', class(obj) );
      end
      if ( ~isa(B, 'Categorical') )
        error( 'Cannot append objects of class "%s".', class(B) );
      end
      
      cat_api( 'append', obj.id, B.id );
    end
    
    function delete(obj)
      
      %   DELETE -- Delete object and free memory.
      %
      %     Calling `clear obj` also deletes the object.
      
      cat_api( 'destroy', obj.id );
    end
    
    function B = copy(obj)
       
      %   COPY -- Create a copy of the current instance.
      %
      %     See also Categorical/Categorical
      %
      %     OUT:
      %       - `B` (Categorical)
      
      B = Categorical( cat_api('copy', obj.id) );
    end
    
    function disp(obj)
      
      %   DISP -- Pretty-print the object's contents.
      %
      %     See also Categorical/Categorical, Categorical/getcats
      
      desktop_exists = usejava( 'desktop' );
      
      if ( desktop_exists )
        link_str = sprintf( '<a href="matlab:helpPopup %s">%s</a>' ...
          , class(obj), class(obj) );
      else
        link_str = class( obj );
      end
      
      if ( ~isvalid(obj) )
        fprintf( 'Handle to deleted %s instance.\n\n', link_str );
        return;
      end
      
      cats = getcats( obj );
      
      if ( numel(cats) == 0 )
        addtl_str = 'with 0 categories';
      else
        addtl_str = 'with labels:';
      end
      
      max_labs = 5;
      
      sz = numel( obj );
      sz_str = sprintf( '%d×1', sz );
      
      fprintf( '  %s %s %s', sz_str, link_str, addtl_str );
      
      if ( numel(cats) > 0 )
        fprintf( '\n' );
      end
      
      n_digits = cellfun( @numel, cats );
      
      max_n_digits = max( n_digits );
      
      for i = 1:numel(cats)
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
      %     See also Categorical/fullcat, Categorical/Categorical
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
      %     See also Categorical/cellstr
      %
      %     OUT:
      %       - `C` (categorical)
      %       - `F` (cell array of strings)
      
      [C, F] = cellstr( obj );
      C = categorical( C );
    end
  end
  
  methods (Static = true)
    
    function obj = from(varargin)
      
      %   FROM -- Create Categorical from compatible source.
      %
      %     C = Categorical.from( c, cats ) creates a Categorical object
      %     from the Matlab categorical array or cell array of strings
      %     `c` and `cats`. `c` is an MxN categorical array or cell array
      %     of strings whose columns correspond to the categories in 
      %     `cats`.
      %
      %     See also Categorical/Categorical
      %
      %     IN:
      %       - `varargin`
      %     OUT:
      %       - `obj` (Categorical)
      
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
        obj = Categorical();
        try
          requirecat( obj, cats );
          for i = 1:numel(cats)
            setcat( obj, cats{i}, arr(:, i) );
          end
        catch err
          delete( obj );
          fprintf( ['\n The following error occurred when\n attempting to create' ...
            , ' a Categorical object\n from cellstr or categorical input:\n\n'] );
          throw( err );
        end
        return;
      end

      error( 'Cannot convert to Categorical from objects of type "%s"', class(arr) );
    end
  end
end