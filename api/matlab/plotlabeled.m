classdef plotlabeled < handle
  
  properties (Access = public)
    summary_func = @plotlabeled.mean;
    error_func = @plotlabeled.std;
    smooth_func = @plotlabeled.noop;
    color_func = @jet;
    fig = [];
    shape = [];
    add_legend = true;
    one_legend = false;
    add_errors = true;
    add_smoothing = false;
    add_points = false;
    plot_empties = true;
    points_are = {};
    points_color_map = [];
    x_tick_rotation = 60;
    main_line_width = 1;
    marker_size = 1;
    marker_type = 'o';
    join_pattern = ' | ';
    y_lims = [];
    match_y_lims = true;
    x_order = {};
    group_order = {};
    panel_order = {}
    x = [];
  end
  
  methods
    function obj = plotlabeled()
      
      %   PLOTLABELED -- Create labeled-plotting interface.
      %
      %     PLOTLABELED objects plot labeled data in intuitive ways,
      %     creating groups and panels for different combinations of
      %     categories.
      %
      %     See also plotlabeled/bar, plotlabeled/lines
      
    end
    
    function axs = lines(obj, data, groups, panels)
      
      %   LINES -- Plot lines for subsets of data.
      %
      %     lines( pl, data, groups, panels ) plots a line for each label
      %     or label combination in `groups`, separately for each label or
      %     label combination in `panels`.
      %
      %     `data` is a labeled object with numeric, 2-dimensional data.
      %
      %     By default, the x-axis is generated automatically as
      %     1:size(data, 2). To use different values for the x-axis, set
      %     the `x` property.
      %
      %     See also plotlabeled/bar, plotlabeled/plotlabeled
      %
      %     IN:
      %       - `data` (labeled)
      %       - `groups` (cell array of strings, char)
      %       - `panels` (cell array of strings, char)
      %     OUT:
      %       - `axs` (axes)
      
      opts = matplotopts( obj, data, {}, groups, panels );
      
      summary_data = opts.summary_data;
      errors_data = opts.errors_data;
      
      if ( ~ismatrix(summary_data) || ~ismatrix(errors_data) )
        error( 'Data must be 2 dimensional.' );
      elseif ( size(summary_data, 2) == 1 )
        error( 'Data must have more than one column.' );
      end
      
      summary_mat = nan( size(summary_data, 2), size(opts.g_combs, 1) );
      errors_mat = nan( size(summary_mat) );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      
      axs = gobjects( 1, n_subplots );
      figure( opts.f );
      
      xdata = get_matx( obj, summary_mat );
      
      for i = 1:n_subplots
        
        ax = subplot( c_shape(1), c_shape(2), i );
        
        %   which rows of `summary` are associated with the current panel?
        panel_ind = find( opts.p_c, opts.p_combs(i, :) );
        
        for j = 1:numel(panel_ind)
          row = panel_ind(j);
          col = find( opts.g_combs, opts.g_c(row, :) );
          summary_mat(:, col) = summary_data(row, :);
          errors_mat(:, col) = errors_data(row, :);
        end
        
        if ( obj.add_smoothing )
          for j = 1:size(summary_mat, 2)
            summary_mat(:, j) = obj.smooth_func( summary_mat(:, j) );
            errors_mat(:, j) = obj.smooth_func( errors_mat(:, j) );
          end
        end
        
        h = plot( xdata, summary_mat );
        
        set( h, 'linewidth', obj.main_line_width );
        
        if ( obj.add_errors )
          plotlabeled.plot_error_ribbon( ax, h, xdata, summary_mat, errors_mat );
        end
        
        summary_mat(:) = NaN;
        errors_mat(:) = NaN;
        
        conditional_add_legend( obj, h, opts.g_labs, i == 1 );
        title( opts.p_labs(i, :) );
        
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
    end
    
    function axs = bar(obj, data, xcat, groups, panels)
      
      %   BAR -- Plot bars for subsets of data.
      %
      %     bar( pl, data, xis, groups, panels ) plots a bar for each label
      %     or label combination in `xis`, grouping bars for each `groups`,
      %     separately for each `panels`.
      %
      %     `data` is a labeled object with numeric data arranged in a
      %     row-vector.
      %
      %     See also plotlabeled/lines, plotlabeled/errorbar
      %
      %     IN:
      %       - `data` (labeled)
      %       - `groups` (cell array of strings, char)
      %       - `panels` (cell array of strings, char)
      %     OUT:
      %       - `axs` (axes)
      
      axs = groupplot( obj, 'bar', data, xcat, groups, panels );
    end
    
    function axs = errorbar(obj, data, xcat, groups, panels)
      
      %   ERRORBAR -- Plot lines with errors for subsets of data.
      %
      %     errorbar( pl, data, xis, groups, panels ) plots an errorbar 
      %     for each label or label combination in `xis`, grouping bars for 
      %     each `groups`, separately for each `panels`.
      %
      %     `data` is a labeled object with numeric data arranged in a
      %     row-vector.
      %
      %     See also plotlabeled/lines, plotlabeled/bar
      %
      %     IN:
      %       - `data` (labeled)
      %       - `groups` (cell array of strings, char)
      %       - `panels` (cell array of strings, char)
      %     OUT:
      %       - `axs` (axes)
      
      axs = groupplot( obj, 'errorbar', data, xcat, groups, panels );
    end
    
    function [axs, identifiers] = scatter(obj, X, Y, labels, groups, panels)
      
      %   SCATTER -- Create grouped scatter plots for subsets of data.
      %
      %     scatter( pl, X, Y, labels, groups, panels ) scatters subsets of
      %     data `X` and `Y`, grouping points for each label or label
      %     combination in `groups`, separately for each `panels`.
      %     Combinations are identified by the fcat object `labels`.
      %
      %     `X` and `Y` must be column vectors of the same size; `labels`
      %     must be an fcat object with the same number of rows as `X` and
      %     `Y`.
      %
      %     axs = scatter(...) returns an array of axes handles `axs`.
      %
      %     [..., ids] = scatter(...) also returns `ids`, a struct array
      %     containing information about the plotted subsets. Each element
      %     of `ids` has fields 'index', 'selectors', 'axes', and 'series'.
      %     'index' is the array of uint64 indices used to select rows of 
      %     `X` and `Y`. 'selectors' is the cell array of string labels 
      %     that generated that index. 'axes' is a handle to the axis in 
      %     which the subsets of `X` and `Y` are scattered. 'series' is a
      %     handle to the scatter plotted data series.
      %
      %     EX //
      %
      %     pl = plotlabeled()
      %
      %     X = rand( 1000, 1 );
      %     Y = rand( 1000, 1 ) * 10;
      %
      %     f = fcat.example();
      %     ind = randperm( length(f), 1000 );
      %     keep( f, ind )
      %
      %     pl.scatter( X, Y, f, 'dose', 'monkey' )
      %
      %     See also plotlabeled/lines, plotlabeled/bar
      %
      %     IN:
      %       - `X` (/T/)
      %       - `Y` (/T/)
      %       - `labels` (fcat)
      %       - `groups` (cell array of strings, char)
      %       - `panels` (cell array of strings, char)
      %     OUT:
      %       - `axs` (axes)
      %       - `ids` (array of struct)
      
      validate_scatter( obj, X, Y, labels );
      
      summarize = false;
      
      try
        opts = matplotopts( obj, labels, {}, groups, panels, summarize );
      catch err
        throwAsCaller( err );
      end
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      
      g_combs = opts.g_combs;
      p_combs = opts.p_combs;
      
      g_labs = opts.g_labs;
      p_labs = opts.p_labs;
      
      axs = gobjects( 1, n_subplots );
      figure( opts.f );
      
      n_groups = double( size(g_combs, 1) );
      colors = obj.color_func( n_groups );
      
      non_empties = true( size(g_labs) );
      
      identifiers = get_identifiers();
      stp = 1;
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        set( ax, 'nextplot', 'add' );
        
        p_ind = find( labels, p_combs(i, :) );
        
        h = gobjects(1, n_groups);
        non_empties(:) = true;
        
        for j = 1:n_groups
          g_ind = intersect( p_ind, find(labels, g_combs(j, :)) );
          
          %   don't include empties
          if ( isempty(g_ind) && ~obj.plot_empties )
            non_empties(j) = false;
            continue;
          end
          
          color = repmat( colors(j, :), numel(g_ind), 1 );
          
          h(j) = scatter( ax, X(g_ind), Y(g_ind), obj.marker_size, color );
          
          %   only add identifiers if requested
          if ( nargout > 1 )
            identifiers(stp) = struct( ...
                'axes', ax ...
              , 'series', h(j) ...
              , 'index', g_ind ...
              , 'selectors', { [g_combs(j, :), p_combs(i, :)] } ...
              );
            stp = stp + 1;
          end
        end
        
        conditional_add_legend( obj, h(non_empties), g_labs(non_empties), i == 1 );
        title( ax, p_labs(i, :) );
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
      
      function s = get_identifiers()
        s = struct( 'axes', {}, 'series', {}, 'index', {}, 'selectors', {} );
      end
    end
  end
  
  methods (Access = private)
    
    function conditional_add_legend(obj, handles, g_labs, first_loop)
      
      %   CONDITIONAL_ADD_LEGEND -- Internal utility to add legend if
      %     requested.
      
      if ( obj.add_legend && (~obj.one_legend || first_loop) )
        legend( handles, g_labs );
      end
    end
    
    function validate_scatter(obj, X, Y, labels)
      
      %   VALIDATE_SCATTER -- Internal utility to validate scatter plot
      %     input.
      
      try
        plotlabeled.assert_isa( labels, 'fcat', 'data labels' );

        dim_msg = ['X and Y data must be column vectors with the same number' ...
          , ' of rows as labels.'];

        assert( isvector(X) && isvector(Y) && size(labels, 1) == numel(X) && ...
          isequal(size(X), size(Y)) && size(X, 2) == 1, dim_msg );
      catch err
        throwAsCaller( err );
      end
    end
    
    function opts = matplotopts(obj, data, xcats, groups, panels, summarize)
      
      %   MATPLOTOPTS -- Internal utility to obtain data subsets.
      
      if ( nargin < 6 )
        summarize = true;
        plotlabeled.assert_isa( data, 'labeled', 'plotted data' );
      else
        plotlabeled.assert_isa( data, 'fcat', 'data labels' );
      end
      
      plotlabeled.assert_isa( obj, 'plotlabeled', 'plot object' );
      
      data = prune( copy(data) );
      
      assert( size(data, 1) >= 1, 'Data cannot be empty.' );
      
      [xcats, groups, panels] = plotlabeled.cell( xcats, groups, panels );
      [xcats, groups, panels] = plotlabeled.uniques( xcats, groups, panels );
      
      specificity = [ xcats, groups, panels ];
      
      %   ensure all categories exist.
      validate_categories( data, specificity );
      
      if ( summarize )
        [summary, I, C] = each( copy(data), specificity, obj.summary_func );
        errors = each( copy(data), specificity, obj.error_func );

        summary_data = summary.data;
        errors_data = errors.data;

        if ( ~isequal(size(summary_data), size(errors_data)) )
          error( ['The output of the summary function and error function' ...
            , ' must produce data of the same size.'] );
        end
      else
        [I, C] = findall( data, specificity );
        
        summary_data = [];
        errors_data = [];
      end
      
      C = C';
      
      x_n = numel( xcats );
      g_n = numel( groups );
      p_n = numel( panels );
      
      x_cols = 1:x_n;      
      g_cols = x_n + (1:g_n);
      p_cols = x_n + g_n + (1:p_n);
      
      x_c = fcat.from( C(:, x_cols), xcats );
      p_c = fcat.from( C(:, p_cols), panels );
      g_c = fcat.from( C(:, g_cols), groups );
      
      x_combs = fcat.from( combs(data, xcats)', xcats );
      p_combs = fcat.from( combs(data, panels)', panels );
      g_combs = fcat.from( combs(data, groups)', groups );
      
      %   order panels, groups, and x ticks, if specified
      keep( x_combs, plotlabeled.orderby(x_combs, obj.x_order) );
      keep( g_combs, plotlabeled.orderby(g_combs, obj.group_order) );
      keep( p_combs, plotlabeled.orderby(p_combs, obj.panel_order) );
      
      g_labs = plotlabeled.joinrows( cellstr(g_combs), obj.join_pattern );
      x_labs = plotlabeled.joinrows( cellstr(x_combs), obj.join_pattern );
      p_labs = plotlabeled.joinrows( cellstr(p_combs), obj.join_pattern );
      
      n_subplots = double( size(p_combs, 1) );
      
      c_shape = get_shape( obj, n_subplots );
      
      f = get_figure( obj );
      clf( f );
      
      opts = struct();
      opts.summary_data = summary_data;
      opts.errors_data = errors_data;
      opts.I = I;
      opts.C = C;
      
      opts.x_c = x_c;
      opts.g_c = g_c;
      opts.p_c = p_c;
      
      opts.x_combs = x_combs;
      opts.g_combs = g_combs;
      opts.p_combs = p_combs;
      
      opts.x_labs = strrep( x_labs, '_', ' ' );
      opts.g_labs = strrep( g_labs, '_', ' ' );
      opts.p_labs = strrep( p_labs, '_', ' ' );
      
      opts.c_shape = c_shape;
      opts.n_subplots = n_subplots;
      opts.f = f;
      
      function validate_categories(obj, spec)
        % 
        %   Ensure categories exist
        %
        cats_exist = hascat( obj, spec );
        if ( ~all(cats_exist) )
          missing = strjoin( spec(~cats_exist), ' | ' );
          error( 'The following categories do not exist: \n\n%s', missing );
        end       
      end
    end
    
    function axs = groupplot(obj, func_name, data, xcats, groups, panels)
      
      %   GROUPPLOT -- Internal utility to plot grouped, row-vector data.
      
      opts = matplotopts( obj, data, xcats, groups, panels );
      
      summary_data = opts.summary_data;
      errors_data = opts.errors_data;
      
      plotlabeled.assert_rowvec( summary_data, 'plotted data' );
      plotlabeled.assert_rowvec( errors_data, 'errors data' );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      
      x_c = opts.x_c;
      g_c = opts.g_c;
      p_c = opts.p_c;
      
      x_combs = opts.x_combs;
      g_combs = opts.g_combs;
      p_combs = opts.p_combs;
      
      x_labs = opts.x_labs;
      g_labs = opts.g_labs;
      p_labs = opts.p_labs;
      
      axs = gobjects( 1, n_subplots );
      figure( opts.f );
      
      summary_mat = nan( size(x_combs, 1), size(g_combs, 1) );
      errors_mat = nan( size(summary_mat) );
      inds_mat = nan( size(summary_mat) );
      
      color_map = get_points_color_map( obj );
      
      for i = 1:n_subplots
        
        ax = subplot( c_shape(1), c_shape(2), i );
        
        %   which rows of `summary` are associated with the current panel?
        panel_ind = find( p_c, p_combs(i, :) );
        
        for j = 1:numel(panel_ind)
          full_row_ind = panel_ind(j);
          row = find( x_combs, x_c(full_row_ind, :) );
          col = find( g_combs, g_c(full_row_ind, :) );
          
          summary_mat(row, col) = summary_data(full_row_ind);
          errors_mat(row, col) = errors_data(full_row_ind);
          inds_mat(row, col) = full_row_ind;
        end
        
        switch ( func_name )
          case 'bar'
            if ( obj.add_errors )
              h = plotlabeled.barwitherr( errors_mat, summary_mat );
            else
              h = bar( summary_mat );
            end
          case 'errorbar'
            if ( obj.add_errors )
              h = errorbar( summary_mat, errors_mat );
            else
              h = errorbar( summary_mat, nan(size(errors_mat)) );
            end
          otherwise
            error( 'Unrecognized function name "%s".', func_name );
        end
        
        summary_mat(:) = NaN;
        errors_mat(:) = NaN;
        
        conditional_add_legend( obj, h, g_labs, i == 1 );
        
        n_ticks = size( summary_mat, 1 );
        
        set( ax, 'xtick', 1:n_ticks );
        set( ax, 'xticklabel', x_labs );
        set( ax, 'xticklabelrotation', obj.x_tick_rotation );
        
        if ( strcmp(func_name, 'errorbar') )
          set( ax, 'xlim', [0, n_ticks+1] );
        end
        
        if ( obj.add_points )
          plot_points( obj, ax, h, data, inds_mat, opts.I, color_map );
        end
        
        title( p_labs(i, :) );
        
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
    end
    
    function plot_points(obj, ax, hs, data, inds, I, colors)
      
      %   PLOT_POINTS -- Overlay points atop bars or errorbars.
      
      set( ax, 'nextplot', 'add' );
      
      values = data.data;
      labs = getlabels( data );
      
      [pt_i, pt_c] = findall( labs, obj.points_are );
      
      pt_c = plotlabeled.joinrows( pt_c', obj.join_pattern );
      
      if ( isempty(pt_i) )
        pt_i = { 1:size(data, 1) };
        pt_c = repmat( {'<undefined>'}, size(pt_i) );
      end
      
      already_displayed = containers.Map();
      auto_colors = obj.color_func( numel(pt_i) );
      
      for i = 1:numel(hs)
        h = hs(i);
        matching_inds = inds(:, i);
        x_offset = get( h, 'xoffset' );
        x_data = get( h, 'xdata' );
        for j = 1:numel(matching_inds)
          ind = I{matching_inds(j)};
          
          for k = 1:numel(pt_i)
            
            full_ind = intersect( ind, pt_i{k} );
            
            if ( isempty(full_ind) ), continue; end
            
            key = pt_c{k};
            
            if ( isKey(colors, key) )
              color = colors(key);
              if ( isKey(already_displayed, key) )
                add_display_name = false;
              else
                add_display_name = true;
                already_displayed(key) = 0;
              end
            else
              color = auto_colors(k, :);
              colors(key) = color;
              add_display_name = true;
              already_displayed(key) = 0;
            end
            
            plot_cmds = { obj.marker_type, 'markersize', obj.marker_size };
            
            if ( add_display_name )
              plot_cmds(end+1:end+2) = { 'displayname', key };
            else
              plot_cmds(end+1:end+2) = { 'handlevisibility', 'off' };
            end
            
            subset_values = values(full_ind);
            x_points = repmat( x_data(j) + x_offset, size(subset_values) );
            h_p = plot( ax, x_points, subset_values, plot_cmds{:} );
            set( h_p, 'color', color );  
            
            if ( verLessThan('matlab', '9.2') && add_display_name )
              legend( 'off' );
              legend( 'show' );
            end
          end
        end
      end
      
      set( ax, 'nextplot', 'replace' );
    end
    
    function m = get_points_color_map(obj)
      
      %   GET_POINTS_COLOR_MAP 
      
      if ( isempty(obj.points_color_map) )
        m = containers.Map();
      else
        m = obj.points_color_map;
      end
    end
    
    function x = get_matx(obj, summary_data)
      
      %   GET_MATX -- Get x coordinates for 2d data.
      
      rows = size( summary_data, 1 );
      cols = size( summary_data, 2 );
      
      if ( isempty(obj.x) )
        x = repmat( (1:rows)', 1, cols );
      else
        if ( numel(obj.x) ~= rows )
          %
          %   plotting requires transposed data, so we check against rows
          %   even though, intuitively, it should be columns
          %
          error( ['X data do not correspond to the plotted data. X data have' ...
            , ' %d values; plotted data have %d columns.'], numel(obj.x), rows );
        end
        x = repmat( obj.x(:), 1, cols );        
      end
    end
    
    function f = get_figure(obj)
      
      %   GET_FIGURE
      
      if ( isempty(obj.fig) || ~isvalid(obj.fig) )
        f = figure(1);
      else
        f = obj.fig;
      end
    end
    
    function l = get_lims(obj, axs, kind)
      
      %   GET_LIMS
      
      l = get( axs(:), kind );
      
      if ( numel(axs) > 1 )
        l = cell2mat( l );
      end
    end
    
    function l = get_ylims(obj, axs)
      
      %   GET_YLIMS
      
      if ( ~isempty(obj.y_lims) )
        l = obj.y_lims;
      elseif ( obj.match_y_lims )
        all_lims = get_lims( obj, axs, 'ylim' );
        l = [ min(all_lims(:, 1)), max(all_lims(:, 2)) ];
      else
        l = get_lims( obj, axs, 'ylim' );
      end
    end
    
    function set_lims(obj, axs, kind, lims)
      
      %   SET_LIMS
      
      if ( size(lims, 1) == 1 )
        arrayfun( @(x) set(x, kind, lims), axs );
      else
        for i = 1:size(lims, 1)
          set( axs(i), kind, lims(i, :) );
        end
      end
    end
    
    function s = get_shape(obj, n)
      
      %   GET_SHAPE
      
      if ( isempty(obj.shape) )
        s = plotlabeled.get_subplot_shape( n );
      else
        s = obj.shape;
        if ( prod(s) < n )
          warning( 'Number of subplots exceeds manually specified shape.' );
          s = plotlabeled.get_subplot_shape( n );
        end
      end
    end
  end
  
  methods (Static = true, Access = public)
    
    function y = noop(x)
      
      %   NOOP
      
      y = x;
    end
    
    function y = std(x)
      
      %   STD -- Standard deviation across the first dimension.
      
      y = std( x, [], 1 );
    end
    
    function y = mean(x)
      
      %   MEAN -- Mean across the first dimension.
      
      y = mean( x, 1 );
    end
    
    function y = nanmean(x)
      
      %   NANMEAN -- Mean across the first dimension, excluding NaN.
      
      y = nanmean( x, 1 );
    end
    
    function y = nanstd(x)
      
      %   NANSTD -- Std across the first dimension, excluding NaN.
      
      y = nanstd( x, [], 1 );
    end
    
    function y = nansem(x)
      
      %   NANSEM -- Std error across the first dimension, excluding NaN.
      
      nans = isnan( x );
      ns = size( x, 1 ) - sum( nans, 1 );
      y = nanstd( x, [], 1 ) ./ sqrt( ns );
      y(:, ns == 0) = NaN;
    end
    
    function y = sem(x)
      
      %   SEM -- Standard error across the first dimension.
      %
      %     IN:
      %       - `x` (double) -- Data.
      %     OUT:
      %       - `y` (double) -- Vector of the same size as `x`.
      
      N = size( x, 1 );
      y = std( x, [], 1 ) / sqrt( N );
    end
    
    function shape = get_subplot_shape(N)
      
      %   GET_SUPLOT_SHAPE -- Get MxN subplot shape from linear size.
      %
      %     IN:
      %       - `N` (double)
      %     OUT:
      %       - `shape` (double)

      if ( N <= 3 )
        shape = [ 1, N ];
        return;
      end

      n_rows = round( sqrt(N) );
      n_cols = ceil( N/n_rows );
      shape = [ n_rows, n_cols ];
    end
  end
    
  methods (Static = true, Access = private)
    
    function [summary_mat, errors_mat] = apply_smoothing(summary_mat, errors_mat, func)
      
      %   APPLY_SMOOTHING -- Internal utility to smooth data and errors.
      
      for i = 1:size(summary_mat, 2)
        summary_mat(:, i) = func( summary_mat(:, i) );
        errors_mat(:, i) = func( errors_mat(:, i) );
      end
    end
    
    function [h1, h2] = plot_error_ribbon(ax, h, xdata, summary_mat, errors_mat)
      
      %   PLOT_ERROR_RIBBON -- Internal utility to add error ribbons.
      
      set( ax, 'nextplot', 'add' );
      line_color = get( h, 'color' );

      h1 = plot( xdata, summary_mat + errors_mat );
      h2 = plot( xdata, summary_mat - errors_mat );

      line_color = plotlabeled.cell( line_color );

      for j = 1:numel(h1)
        set( h1(j), 'color', line_color{j} );
        set( h2(j), 'color', line_color{j} );
      end

      set( ax, 'nextplot', 'replace' );
    end
    
    function I = orderby( actual, preferred )
      
      %   ORDERBY -- Get an index of elements as ordered by another set.
      %
      %     IN:
      %       - `actual` (cell array of strings) -- Labels as obtained from
      %         get_indices().
      %       - `preferred` (cell array of strings) -- The preferred order
      %         of those labels. Elements in `preferred` not found in
      %         `actual` will be skipped.
      %     OUT:
      %       - `I` (double) -- Numeric index of the elements in
      %         `actual` as sorted by `preferred`.
      
      if ( isa(actual, 'fcat') )
        actual = cellstr( actual );
      end
      I = (1:size(actual, 1))';
      if ( numel(preferred) == 0 )
        return;
      end
      inds = cellfun( @(x) find(strcmp(preferred, x)), actual, 'un', false );
      empties = cellfun( @isempty, inds );
      inds( empties ) = { Inf };
      inds = cell2mat( inds );
      for i = 1:size( inds, 2 )
        [~, sort_ind] = sort( inds(:, i) );
        I = I( sort_ind, : );
        inds = inds( sort_ind, : );        
      end
    end
    
    function joined = joinrows(C, join_char)
      
      %   JOINROWS
      
      if ( nargin < 2 )
        join_char = ' | ';
      end
      
      joined = cell( size(C, 1), 1 );
      
      for i = 1:size(C, 1)
        joined{i} = strjoin( C(i, :), join_char );
      end
    end
    
    function varargout = uniques(varargin)
      
      %   UNIQUES
      
      varargout = cell( size(varargin) );
      
      for i = 1:numel(varargin)
        varargout{i} = unique( varargin{i} );
      end
    end
    
    function varargout = cell(varargin)
      
      %   CELL
      
      varargout = cell( size(varargin) );
      
      for i = 1:numel(varargin)
        if ( ~iscell(varargin{i}) )
          varargout{i} = { varargin{i} };
        else
          varargout{i} = varargin{i};
        end
      end
    end
    
    function varargout = barwitherr(errors,varargin)
      
      %   BARWITHERR -- Plot a bar plot with error bars.
      %
      %     Search fileexchange for 'barwitherr'

      % Check how the function has been called based on requirements for "bar"
      if nargin < 3
          % This is the same as calling bar(y)
          values = varargin{1};
          xOrder = 1:size(values,1);
      else
          % This means extra parameters have been specified
          if isscalar(varargin{2}) || ischar(varargin{2})
              % It is a width / property so the y values are still varargin{1}
              values = varargin{1};
              xOrder = 1:size(values,1);
          else
              % x-values have been specified so the y values are varargin{2}
              % If x-values have been specified, they could be in a random order,
              % get their indices in ascending order for use with the bar
              % locations which will be in ascending order:
              values = varargin{2};
              [tmp xOrder] = sort(varargin{1});
          end
      end

      % If an extra dimension is supplied for the errors then they are
      % assymetric split out into upper and lower:
      if ndims(errors) == ndims(values)+1
          lowerErrors = errors(:,:,1);
          upperErrors = errors(:,:,2);
      elseif isvector(values)~=isvector(errors)
          lowerErrors = errors(:,1);
          upperErrors = errors(:,2);
      else
          lowerErrors = errors;
          upperErrors = errors;
      end
      % Check that the size of "errors" corresponsds to the size of the y-values.
      % Arbitrarily using lower errors as indicative.
      if any(size(values) ~= size(lowerErrors))
          error('The values and errors have to be the same length')
      end

      [nRows nCols] = size(values);
      if ( nRows > 1 )
        handles.bar = bar(varargin{:}); % standard implementation of bar fn
      else
        mat = repmat( varargin{:}, 2, 1 );
        handles.bar = bar( mat );
        for i = 1:numel(handles.bar)
          handles.bar(i).XData = 1;
          handles.bar(i).YData = handles.bar(i).YData(1);
        end
      end
      hold on
      hBar = handles.bar;

      if nRows > 0
          hErrorbar = zeros(1,nCols);
          for col = 1:nCols
              % Extract the x location data needed for the errorbar plots:
              if verLessThan('matlab', '8.4')
                  % Original graphics:
                  x = get(get(handles.bar(col),'children'),'xdata');
              else
                  % New graphics:
                  x =  handles.bar(col).XData + [handles.bar(col).XOffset];
              end
              % Use the mean x values to call the standard errorbar fn; the
              % errorbars will now be centred on each bar; these are in ascending
              % order so use xOrder to ensure y values and errors are too:
              hErrorbar(col) = errorbar(mean(x,1), values(xOrder,col), lowerErrors(xOrder,col), upperErrors(xOrder, col), '.k');
              set(hErrorbar(col), 'marker', 'none')
          end
      else
        hErrorbar = zeros(1,nCols);
        for col = 1:nCols
            % Extract the x location data needed for the errorbar plots:
            if verLessThan('matlab', '8.4')
                % Original graphics:
                x = get(get(handles.bar(1),'children'),'xdata');
            else
                % New graphics:
                x =  handles.bar(1).XData + [handles.bar(1).XOffset];
            end
            % Use the mean x values to call the standard errorbar fn; the
            % errorbars will now be centred on each bar; these are in ascending
            % order so use xOrder to ensure y values and errors are too:
            hErrorbar(col) = errorbar(x(col), values(xOrder,col), lowerErrors(xOrder,col), upperErrors(xOrder, col), '.k');
            set(hErrorbar(col), 'marker', 'none')
        end
      end
      hold off
      switch nargout
          case 1
              varargout{1} = hBar;
          case 2
              varargout{1} = hBar;
              varargout{2} = hErrorbar;
      end   
    end
    
    function assert_isa(data, cls, kind)
      
      %   ASSERT_ISA
      
      if ( nargin < 2 ), kind = '(unspecified)'; end
      if ( ~isa(data, cls) )
        error( 'Data of type "%s" must be a "%s"; was a "%s".' ...
          , kind, cls, class(data) );
      end
    end
    
    function assert_rowvec(data, kind)
      
      %   ASSERT_ROWVEC
      
      if ( nargin < 2 ), kind = '(unspecified)'; end
      if ( ~ismatrix(data) || size(data, 2) > 1 )
        error( 'Data of type "%s" must be a row vector.', kind );
      end
    end
    
    function assert_colvec(data, kind)
      
      %   ASSERT_COLVEC
      
      if ( nargin < 2 ), kind = '(unspecified)'; end
      if ( ~ismatrix(data) || size(data, 1) > 1 )
        error( 'Data of type "%s" must be a row vector.', kind );
      end
    end
    
    function assert_isvector(data, kind)
      
      %   ASSERT_ISVECTOR
      
      if ( nargin < 2 ), kind = '(unspecified)'; end
      if ( ~isvector(data) )
        error( 'Data of type "%s" must be a vector.', kind );
      end
    end
  end
  
end