classdef plotlabeled < handle
  
  properties (Access = private, Constant = true)
    %   When categories are input as {}, a dummy category is added.
    %   This specifies the pattern used to create the dummy category.
    DUMMY_CATEGORY_PATTERN = 'undefined %d';
  end
  
  properties (Access = public)
    summary_func = @plotlabeled.mean;
    error_func = @plotlabeled.std;
    smooth_func = @plotlabeled.noop;
    color_func = @jet;
    fit_func = @(x, y) x;
    fig = [];
    shape = [];
    add_fit = false;
    add_legend = true;
    one_legend = false;
    add_errors = true;
    add_smoothing = false;
    add_points = false;
    add_x_tick_labels = true;
    per_panel_labels = false;
    plot_empties = true;
    points_are = {};
    points_color_map = [];
    point_jitter = 0;
    x_tick_rotation = 60;
    invert_y = false;
    main_line_width = 1;
    marker_size = 1;
    marker_type = 'o';
    join_pattern = ' | ';
    x_lims = [];
    y_lims = [];
    c_lims = [];
    r_lims = [];
    match_x_lims = true;
    match_y_lims = true;
    match_c_lims = true;
    match_r_lims = true;
    x_order = {};
    group_order = {};
    panel_order = {};
    x = [];
    y = [];
    sort_combinations = false;
    mask = 'off';
    prefer_multiple_groups = false;
    prefer_multiple_xs = false;
    errorbar_connect_non_nan = false;
    pie_include_percentages = false;
  end
  
  methods
    function obj = plotlabeled(varargin)
      
      %   PLOTLABELED -- Create labeled-plotting interface.
      %
      %     PLOTLABELED objects plot labeled data in intuitive ways,
      %     creating groups and panels for different combinations of
      %     categories.
      %
      %     obj = plotlabeled() creates a default-constructed PLOTLABELED
      %     object. Properties can be modified using '.' notation.
      %
      %     obj = plotlabeled( 'prop1', val1, ... ) assigns val1 to the
      %     property 'prop1'. Use properties( obj ) to get a list of valid
      %     property names.
      %
      %     See also plotlabeled/bar, plotlabeled/lines
      
      try
        assign_pair_inputs( obj, varargin );
      catch err
        throw( err );
      end
    end
    
    function obj = set_property(obj, prop, value)
      
      %   SET_PROPERTY -- Set property to value.
      %
      %     set_property( obj, prop, to ); assigns `to` to property `prop`,
      %     a char vector property name.
      %
      %     See also plotlabeled
      
      obj.(prop) = value;
    end
    
    function pl = set_smoothing(pl, func_or_amt)
      
      %   SET_SMOOTHING -- Add smoothing function and flag to object.
      %
      %     set_smoothing( obj, AMOUNT ) sets the `smooth_func` property to 
      %     a function equivalent to `@(x) smooth(x, AMOUNT)`, and sets 
      %     the `add_smoothing` flag.
      %
      %     set_smoothing( obj, FUNC ) sets the `smooth_func` property to
      %     `FUNC`, and also sets the `add_smoothing` flag.
      
      if ( nargin < 2 )
        func_or_amt = 1;
      end
      
      if ( isnumeric(func_or_amt) )
        smooth_func = @(x) smooth(x, func_or_amt); %#ok
      else
        smooth_func = func_or_amt; %#ok
      end
      
      pl.add_smoothing = true;
      pl.smooth_func = smooth_func; %#ok
    end
    
    function [figs, axes, I, axes_indices] = ...
        figures(obj, func, data, labels, figcats, varargin)
      
      %   FIGURES -- Generate plots in separate figures for subsets of data.
      %
      %     figs = figures( pl, func, data, labels, figcats, ... ) calls
      %     the plotting function `func` for each combination of labels in
      %     `figcats` categories, plotting each in a separate figure.
      %     `func` is a function like `lines`, `bar`, etc. that takes
      %     `data` and an fcat object `labels`, and additional category
      %     specifiers. output `figs` is an array of figure handles.
      %
      %     [..., axes] = figures(...) also returns an Mx1 vector of axes
      %     handles `axes`, containing all of the axes across `figs`.
      %
      %     [..., I] = figures(...) also returns a cell array of index
      %     vectors identifying subsets of `data` and `labels` plotted in 
      %     each figure. `I` has the same number of elements as `figs`.
      %
      %     [..., axes_indices] = figures(...) also returns a vector the
      %     same size as `axes`, whose elements give the index of the
      %     figure in `figs` to which each axis belongs.
      %
      %     EX //
      %
      %     labs = fcat.example();
      %     dat = fcat.example( 'smalldata' );
      %     pl = plotlabeled.make_common();
      %     %   plot bar graphs with bars for each 'image', grouped by each 
      %     %   'dose', with panels for each 'roi'--in a separate figure
      %     %   for each 'roi'
      %     figs = pl.figures( @bar, dat, labs, 'roi', 'image', 'dose', 'roi' );
      %
      %     See also plotlabeled/lines, plotlabeled/bar, plotlabeled
      
      assert_ispair( data, labels );
      assert_hascat( labels, figcats );
      assert( ~has_mask(obj), 'Masking with figures is not yet supported.' );
      
      if ( iscell(figcats) && isempty(figcats) )
        I = { fcat.mask(labels) };
      else
        I = findall( labels, figcats );
      end
      
      figs = cell( size(I) );
      axes = cell( size(I) );
      axes_indices = cell( size(I) );
      
      current_fig = obj.fig;
      
      for i = 1:numel(I)
        obj.fig = figure(i);
        
        ind = I{i};
        axs = func( obj, rowref(data, ind), labels(ind), varargin{:} );
        
        figs{i} = obj.fig;
        axes{i} = axs(:);
        axes_indices{i} = repmat( i, numel(axs), 1 );
      end
      
      figs = vertcat( figs{:} );
      axes = vertcat( axes{:} );
      axes_indices = vertcat( axes_indices{:} );
      
      obj.fig = current_fig;
    end
    
    function [axs, hs, inds] = lines(obj, varargin)
      
      %   LINES -- Plot lines for subsets of data.
      %
      %     lines( pl, data, groups, panels ) plots a line for each label
      %     or label combination in `groups`, separately for each label or
      %     label combination in `panels`.
      %
      %     `data` is a labeled object with numeric, 2-dimensional data.
      %
      %     lines( pl, data, labels, ... ) works as above, except that
      %     `data` is a numeric matrix, and `labels` is an fcat object with
      %     the same number of rows as `data`.
      %
      %     axs = lines(...) returns an array of handles to the created
      %     axes.
      %
      %     [..., hs] = lines(...) also returns `hs`, a cell array of
      %     handles to the plotted line objects. `hs` has the same size as
      %     `axs`.
      %
      %     [..., inds] = lines(...) also returns `inds`, a cell array of
      %     cell arrays of uint64 indices identifying, for each line, the
      %     elements of the input data used to generate that line.
      %
      %     By default, the x-axis is generated automatically as
      %     1:size(data, 2). To use different values for the x-axis, set
      %     the `x` property.
      %
      %     Pass in an empty cell array ({}) for either groups or panels 
      %     in order to avoid specifying that dimension.
      %
      %     See also plotlabeled/bar, plotlabeled/plotlabeled
      
      try
        [data, gp] = plotlabeled.parse_varargin( varargin, 3 );
      catch err
        throw( err );
      end
      
      groups = gp{1};
      panels = gp{2};
      
      try
        opts = matplotopts( obj, data, {}, groups, panels );
      catch err
        throw( err );
      end
      
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
      
      xdata = get_matx( obj, summary_mat );
      
      hs = cell( n_subplots, 1 );
      inds = cell( n_subplots, 1 );
      
      for i = 1:n_subplots
        
        ax = subplot( c_shape(1), c_shape(2), i );
        inds{i} = {};
        
        %   which rows of `summary` are associated with the current panel?
        panel_ind = find( opts.p_c, opts.p_combs(i, :) );
        
        for j = 1:numel(panel_ind)
          row = panel_ind(j);
          col = find( opts.g_combs, opts.g_c(row, :) );
          summary_mat(:, col) = summary_data(row, :);
          errors_mat(:, col) = errors_data(row, :);
          
          inds{i}{col} = opts.I{row};
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
        hs{i} = h;
        
        if ( numel(inds{i}) < numel(h) )
          inds{i}(end+1:numel(h)) = { [] };
        end
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
    end
    
    function axs = bar(obj, varargin)
      
      %   BAR -- Plot bars for subsets of data.
      %
      %     bar( pl, data, xis, groups, panels ) plots a bar for each label
      %     or label combination in `xis`, grouping bars for each `groups`,
      %     separately for each `panels`.
      %
      %     `data` is a labeled object with numeric data arranged in a
      %     row-vector.
      %
      %     bar( pl, data, labels, ... ) works as above, except that `data`
      %     is a numeric row vector, and `labels` is an fcat object with
      %     the same number of rows as `data`.
      %
      %     Pass in an empty cell array ({}) for any of x, groups, or
      %     panels, in order to avoid specifying that dimension.
      %
      %     See also plotlabeled/lines, plotlabeled/errorbar
      
      try
        axs = groupplot( obj, 'bar', varargin{:} );
      catch err
        throw( err );
      end
    end
    
    function axs = stackedbar(obj, varargin)
      try
        axs = groupplot( obj, 'stacked_bar', varargin{:} );
      catch err
        throw( err );
      end
    end
    
    function axs = errorbar(obj, varargin)
      
      %   ERRORBAR -- Plot lines with errors for subsets of data.
      %
      %     errorbar( pl, data, xis, groups, panels ) plots an errorbar 
      %     for each label or label combination in `xis`, grouping bars for 
      %     each `groups`, separately for each `panels`.
      %
      %     `data` is a labeled object with numeric data arranged in a
      %     row-vector.
      %
      %     errorbar( pl, data, labels, ... ) works as above, except that
      %     `data` is a numeric matrix, and `labels` is an fcat object with
      %     the same number of rows as `data`.
      %
      %     Pass in an empty cell array ({}) for any of x, groups, or
      %     panels, in order to avoid specifying that dimension.
      %
      %     See also plotlabeled/lines, plotlabeled/bar
      
      try
        axs = groupplot( obj, 'errorbar', varargin{:} );
      catch err
        throw( err );
      end
    end
    
    function [axs, hs, indices] = polarhistogram(obj, theta, labels, panels, varargin)
      
      %   POLARHISTOGRAM -- Create polar histograms for subsets of data.
      %
      %     polarhistogram( pl, theta, labels, panels ); creates polar
      %     histograms from the vector of angles `theta`, with separate
      %     panels for each subset of `theta` identified by a combination
      %     of labels in `panels` categories.
      %
      %     polarhistogram( ..., 'name', value ); passes additional name-
      %     value paired arguments to the built-in polarhistogram function.
      %
      %     axs = polarhistogram(...) returns an array of handles to the
      %     created polar axes.
      %
      %     [..., hs] also returns a cell array of handles to the created
      %     polar histogram plots.
      %
      %     [..., indices] also returns a cell array of uint64 index
      %     vectors identifying the subset(s) of `theta` plotted in each
      %     panel.
      %
      %     See also polarhistogram, plotlabeled.hist, 
      %     plotlabeled.pie, plotlabeled, fcat
      
      try
        assert( ~has_mask(obj), 'Masking is not supported with `polarhistogram`.' );

        validate_data_labels( theta, labels );
        opts = matplotopts( obj, labels, {}, {}, panels, false );
      catch err
        throw( err );
      end

      I = opts.I;

      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;

      axs = gobjects( n_subplots, 1 );
      hs = cell( size(axs) );
      indices = cell( size(axs) );

      for i = 1:n_subplots        
        ax = subplot( c_shape(1), c_shape(2), i );
        pax = polaraxes( 'units', ax.Units, 'position', ax.Position );
        delete( ax );

        row = find( opts.p_c, opts.p_combs(i, :) );
        dat = rowref( theta, I{row} );

        hs{i} = polarhistogram( pax, dat, varargin{:} );
        title( pax, opts.p_labs(i, :) );

        indices{i} = I{row};
        axs(i) = pax;
      end
      
      set_lims( obj, axs, 'rlim', get_rlims(obj, axs) );

      function validate_data_labels(data, labels)
        assert( isa(labels, 'fcat'), 'Labels must be fcat; were "%s".', class(labels) );
        assert( size(data, 1) == length(labels) ...
          , 'Length of labels must match number of rows of data.' );
      end
    end
    
    function [axs, hs] = pie(obj, X, labels, groups, panels)
      
      %   PIE -- Create pie charts for subsets of data.
      %
      %     pie( obj, X, labels, groups, panels ) creates pie charts from
      %     the data in `X` whose slices are drawn from `groups`,
      %     separately for each `panels`. Combinations are identified by
      %     the fcat object `labels`.
      %
      %     `X` must be a column vector with the same number of rows as
      %     `labels`.
      %
      %     See also plotlabeled, plotlabeled/bar
      
      validateattributes( X, {'double', 'single'}, {'vector'}, mfilename, 'data' );
      
      try
        opts = matplotopts( obj, labeled(X, labels), {}, groups, panels );
      catch err
        throwAsCaller( err );
      end
      
      num_panels = double( length(opts.p_combs) );
      num_groups = double( length(opts.g_combs) );
      
      hs = cell( num_panels, 1 );
      axs = gobjects( size(hs) );
      
      for i = 1:num_panels
        ax = subplot( opts.c_shape(1), opts.c_shape(2), i );
        
        p_ind = find( opts.p_c, opts.p_combs(i, :) );
        pie_dat = nan( num_groups, 1 );
        
        for j = 1:num_groups
          g_ind = find( opts.g_c, opts.g_combs(j, :), p_ind );
          pie_dat(j) = opts.summary_data(g_ind);
        end
        
        g_labs = opts.g_labs;
        
        if ( obj.pie_include_percentages )
          g_labs = arrayfun( @(x, y) sprintf('%s (%0.3f%%)', x{1}, y) ...
            , g_labs, pie_dat, 'un', 0 );
        end
        
        hs{i} = pie( ax, pie_dat, g_labs );
        title( ax, opts.p_labs(i, :) );
        
        axs(i) = ax;
      end
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
      %     [axs, ids] = pl.scatter( X, Y, f, 'dose', 'monkey' )
      %
      %     See also plotlabeled/lines, plotlabeled/bar
      
      validate_scatter( obj, X, Y, labels );
      
      summarize = false;
      
      try
        opts = matplotopts( obj, labels, {}, groups, panels, summarize );
      catch err
        throwAsCaller( err );
      end
      
      labels = addcat( copy(labels), opts.specificity );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      
      g_combs = opts.g_combs;
      p_combs = opts.p_combs;
      
      g_labs = opts.g_labs;
      p_labs = opts.p_labs;
      
      axs = gobjects( 1, n_subplots );
      
      n_groups = double( size(g_combs, 1) );
      colors = obj.color_func( n_groups );
      
      non_empties = true( size(g_labs) );
      
      identifiers = plotlabeled.get_identifiers();
      stp = 1;
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        set( ax, 'nextplot', 'add' );
        
        p_ind = find( labels, p_combs(i, :) );
        
        h = gobjects(1, n_groups);
        non_empties(:) = true;
        
        for j = 1:n_groups
          g_ind = find( labels, g_combs(j, :), p_ind );
          
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
    end
    
    function axs = boxplot(obj, data, labs, groups, panels, add_means)
      
      %   BOXPLOT -- Create box plots for subsets of data.
      %
      %     boxplot( obj, data, labels, groups, panels ) creates a series
      %     of boxplots with panel labels drawn from the category(ies) in
      %     `panels`, and group labels from the category(ies) in `groups`.
      %     `data` is an Mx1 vector; `labels` is an MxN fcat object.
      %
      %     axs = ... returns an array of handles to the subplotted axes.
      %
      %     Note that, currently, the ordering of groups is not supported.
      %
      %     EX //
      %
      %     f = fcat.example();
      %     dat = fcat.example( 'smalldata' );
      %     pl = plotlabeled();
      %     pl.boxplot( dat, f, 'dose', 'monkey' )
      %
      %     See also plotlabeled/scatter, plotlabeled/bar
      
      try
        validate_data( data, labs );
        opts = matplotopts( obj, labs, {}, groups, panels, false );
      catch err
        throw( err );
      end
      
      if ( nargin < 6 )
        add_means = false;
      end
      
      labs = addcat( copy(labs), opts.specificity );
      M = get_mask( obj, length(labs) );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      g_cats = opts.g_cats;
      
      axs = gobjects( 1, n_subplots );
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        
        I = find( labs, opts.p_combs(i, :), M );
        
        plt_dat = rowref( data, I );
        plt_labs = categorical( labs, g_cats, I );
        
        if ( ~isempty(obj.group_order) )
          boxplot( ax, plt_dat, plt_labs, 'grouporder', obj.group_order );
        else
          boxplot( ax, plt_dat, plt_labs );
        end
        
        if ( add_means )
          plot_means( ax, data, labs, g_cats, I );       
        end
        
        title( ax, opts.p_labs(i, :) );
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
      
      function plot_means(ax, dat, labs, g_cats, current_ind)
        
        g_I = findall( labs, g_cats, current_ind );
        means = rowop( dat, g_I, @(x) nanmean(x, 1) );
        
        hold( ax, 'on' );
        xtick = 1:numel( means );
        
        for j = 1:numel(xtick)
          x0 = xtick(j) - 0.05;
          x1 = xtick(j) + 0.05;
          
          ys = repmat( means(j), 1, 2 );
          
          plot( ax, [x0, x1], ys, 'b' );
        end
      end
      
      function validate_data(data, labs)
        plotlabeled.assert_isa( labs, 'fcat', 'data labels' );
        assert( size(data, 1) == length(labs), ['Number of rows of data' ...
          , ' must match number of rows of labels.'] );
      end
    end
    
    function axs = violinalt(obj, data, labs, groups, panels, varargin)
      
      %   VIOLINALT -- Create violin plots for subsets of data (alternative
      %     method).
      %
      %     violinalt( obj, data, labels, groups, panels ) creates a series
      %     of violin plots with panel labels drawn from the category(ies) in
      %     `panels`, and group labels from the category(ies) in `groups`.
      %     `data` is an Mx1 vector; `labels` is an MxN fcat object.
      %
      %     axs = ... returns an array of handles to the subplotted axes.
      %
      %     This function depends on the violin repository, currently 
      %     available at: https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot
      %
      %     Note that the ordering of groups is not supported.
      %
      %     EX //
      %
      %     f = fcat.example();
      %     dat = fcat.example( 'smalldata' );
      %     pl = plotlabeled();
      %     pl.violinalt( dat, f, 'dose', 'monkey' )
      %
      %     See also plotlabeled/scatter, plotlabeled/bar, plotlabeled/boxplot
      
      validateattributes( labs, {'fcat'}, {}, mfilename, 'labels' );
      validateattributes( data, {'numeric'} ...
        , {'vector', 'column', 'nrows', length(labs)}, mfilename, 'data' );
      
      if ( isempty(which('violin_alt')) )
        error( ['This function depends on the violin repository, ' ...
          , ' available at: https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot' ...
          , ' Additionally, once downloaded, this file must be renamed to "violin_alt".'] );
      end
      
      try
        opts = matplotopts( obj, labs, {}, groups, panels, false );
      catch err
        throw( err );
      end
      
      labs = addcat( copy(labs), opts.specificity );
      M = get_mask( obj, length(labs) );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      g_cats = opts.g_cats;
      
      axs = gobjects( 1, n_subplots );
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        
        I = find( labs, opts.p_combs(i, :), M );
        
        [g_I, g_C] = findall( labs, g_cats, I );
        g_dat = cellfun( @(x) data(x), g_I, 'un', 0 );
        colors = obj.color_func( numel(g_I) );
        
        g_labs = fcat.strjoin( g_C, obj.join_pattern );
        g_labs = cellfun( @(x) strrep(x, '_', ' '), g_labs, 'un', 0 );
        
        h = violin_alt( g_dat(:)' );
        set( ax, 'xtick', 1:numel(g_I) );
        set( ax, 'xticklabel', g_labs );
        
        for j = 1:numel(h)
          set( h(j), 'FaceColor', colors(j, :) );
          set( h(j), 'FaceAlpha', 1 );
        end
        
        title( ax, opts.p_labs(i, :) );
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
    end
    
    function axs = violinplot(obj, data, labs, groups, panels, varargin)
      
      %   VIOLINPLOT -- Create violin plots for subsets of data.
      %
      %     violinplot( obj, data, labels, groups, panels ) creates a series
      %     of violinplots with panel labels drawn from the category(ies) in
      %     `panels`, and group labels from the category(ies) in `groups`.
      %     `data` is an Mx1 vector; `labels` is an MxN fcat object.
      %
      %     violinplot( ..., 'NAME', value ) specifies additional 'name',
      %     value-paired inputs to be passed to the `violinplot` function.
      %     See `help violinplot` for more information.
      %
      %     axs = ... returns an array of handles to the subplotted axes.
      %
      %     This function depends on the Violinplot-Matlab repository,
      %     currently available at: https://github.com/bastibe/Violinplot-Matlab
      %
      %     Note that the ordering of groups is not supported.
      %
      %     EX //
      %
      %     f = fcat.example();
      %     dat = fcat.example( 'smalldata' );
      %     pl = plotlabeled();
      %     pl.violinplot( dat, f, 'dose', 'monkey' )
      %
      %     See also violinplot, plotlabeled/scatter, plotlabeled/bar,
      %       plotlabeled/boxplot
      
      validateattributes( labs, {'fcat'}, {}, mfilename, 'labels' );
      validateattributes( data, {'numeric'} ...
        , {'vector', 'column', 'nrows', length(labs)}, mfilename, 'data' );
      
      if ( isempty(which('violinplot')) )
        error( ['This function depends on the Violinplot-Matlab repository, ' ...
          , ' available at: https://github.com/bastibe/Violinplot-Matlab '] );
      end
      
      try
        opts = matplotopts( obj, labs, {}, groups, panels, false );
      catch err
        throw( err );
      end
      
      labs = addcat( copy(labs), opts.specificity );
      M = get_mask( obj, length(labs) );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      g_cats = opts.g_cats;
      
      axs = gobjects( 1, n_subplots );
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        
        I = find( labs, opts.p_combs(i, :), M );
        
        pltdat = rowref( data, I );
        pltlabs = categorical( labs, g_cats, I );
        
        [cats, ~, ic] = unique( pltlabs, 'rows' );
        xlabs = fcat.strjoin( cellstr(cats)', obj.join_pattern );
        
        grp = cell( length(pltlabs), 1 );
        unique_ic = unique( ic );
        
        for j = 1:numel(unique_ic)
          ind = unique_ic(j);
          
          grp(ic == ind) = xlabs(ind);
        end
        
        violinplot( pltdat, grp, varargin{:} );
        
        title( ax, opts.p_labs(i, :) );
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
    end
    
    function axs = imagesc(obj, varargin)
      
      %   IMAGESC -- Create scaled images for subsets of data.
      %
      %     imagesc( pl, data, 'outcomes' ) creates scaled images whose
      %     panels are drawn from the unique labels in 'outcomes'. `data`
      %     is a labeled object.
      %
      %     imagesc( pl, data, labels, 'outcomes' ) works as above.
      %     `data` in this case is numeric; `labels` is an fcat object with
      %     the same number of rows as `data`.
      %
      %     Plotted data must be a 3-dimensional array: N-by-y-by-x.
      %     `pl.summary_func` is called to collapse the first dimension for
      %     each subset of data. 
      %
      %     axs = imagesc(...) returns an array of axes handles to
      %     each subplot.
      %
      %     Pass in an empty cell array ({}) for panels to avoid specifying 
      %     that dimension.
      %
      %     This function is useful for creating time-series spectrograms, 
      %     in which case data are conceptually an array of N-trials by
      %     M-frequencies by P-time points.
      
      try
        [plt, panels] = validate_and_get_labeled( varargin{:} );
      catch err
        throw( err );
      end
      
      try
        opts = matplotopts( obj, plt, {}, {}, panels );
      catch err
        throw( err );
      end
      
      n_x = size( plt.data, 3 );
      n_y = size( plt.data, 2 );
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      
      axs = gobjects( 1, n_subplots );
      
      xdat = get_x( obj, n_x );
      ydat = get_y( obj, n_y );
      ys = repmat( (1:length(ydat))', 1, length(xdat) );
      
      if ( obj.invert_y )
        ydat = flipud( ydat(:) );
      end
      
      colormap( obj.color_func() );
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        
        panel_ind = find( opts.p_c, opts.p_combs(i, :) );
        
        dat = squeeze( rowref(opts.summary_data, panel_ind) );
        
        if ( obj.invert_y ), dat = flipud( dat ); end
        if ( obj.add_smoothing ), dat = obj.smooth_func( dat ); end
        
        h = imagesc( ax, ys, 'CData', dat );
        cb = colorbar;
        
        xticks = get( ax, 'xtick' );
        yticks = get( ax, 'ytick' );
        
        try
          set( ax, 'xticklabels', xdat(xticks) );
          set( ax, 'yticklabels', ydat(yticks) );
        catch err
          warning( err.message );
        end
        
        title( ax, opts.p_labs{i} );
        
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'clim', get_clims(obj, axs) );
      
      function [plt, panels] = validate_and_get_labeled(varargin)
        
        %   VALIDATE_AND_GET_LABELED -- Get labeled from labeled or data +
        %     fcat.
        
        narginchk( 2, 3 );
        if ( nargin == 3 )
          plt = labeled( varargin{1}, varargin{2} );
          panels = varargin{3};
        else
          plt = varargin{1};
          panels = varargin{2};
          
          plotlabeled.assert_isa( plt, 'fcat', 'labels' );
        end
        
        assert( ndims(plt.data) == 3, ['Data must be 3-dimensional: ' ...
          , ' N-by-y-by-x.'] );
      end
    end
    
    function [axs, indices] = hist(obj, data, labels, panels, varargin)
      
      %   HIST -- Create histograms for subsets of data.
      %
      %     hist( pl, data, labels, panels ) creates histograms whose
      %     panels are drawn from the label combinations in categories 
      %     given by `panels`. `data` is a double matrix; `labels` is an 
      %     fcat object with the same number of rows as `data`.
      %
      %     hist( ..., VARARGIN ) passes additional arguments to the
      %     built-in histogram function.
      %
      %     axs = hist( ... ) returns an array of handles to the created
      %     axes.
      %
      %     See also histogram, plotlabeled/imagesc, plotlabeled/scatter
      
      try
        assert( ~has_mask(obj), 'Masking is not supported with `hist`.' );
        
        validate_data_labels( data, labels );
        opts = matplotopts( obj, labels, {}, {}, panels, false );
      catch err
        throw( err );
      end
      
      I = opts.I;
      
      n_subplots = opts.n_subplots;
      c_shape = opts.c_shape;
      
      axs = gobjects( n_subplots, 1 );
      indices = cell( size(axs) );
      
      for i = 1:n_subplots
        ax = subplot( c_shape(1), c_shape(2), i );
        
        row = find( opts.p_c, opts.p_combs(i, :) );
        
        dat = rowref( data, I{row} );
        
        h = histogram( ax, dat, varargin{:} );
        
        conditional_add_legend( obj, h, opts.g_labs, i == 1 );
        title( ax, opts.p_labs(i, :) );
        
        indices{i} = I{row};
        axs(i) = ax;
      end
            
      set_lims( obj, axs, 'xlim', get_xlims(obj, axs) );
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
      
      function validate_data_labels(data, labels)
        assert( isa(labels, 'fcat'), 'Labels must be fcat; were "%s".', class(labels) );
        assert( size(data, 1) == length(labels) ...
          , 'Length of labels must match number of rows of data.' );
      end
    end
    
    %
    %   GET / SET
    %    
    
    function set.mask(obj, val)
      
      %   SET.MASK -- Validate and set the "mask" property.
      
      if ( strcmp(val, 'off') )
        obj.mask = val;
      else
        classes = { 'uint64', 'logical', 'double' };
        if ( ~ismember(class(val), classes) )
          error( 'Mask must be one of:\n%s', strjoin([classes, '"off"'], ' | ') );
        end
        if ( isa(val, 'logical') ), val = find( val ); end
        obj.mask = val;
      end
    end
  end
  
  methods (Access = private)
    
    function assign_pair_inputs(obj, inputs)
      
      %   ASSIGN_PAIR_INPUTS -- Assign (field, label) pair inputs to new
      %     object.
      %
      %     assign_pair_inputs( obj, {'summary_func', @nanmean} ) is called
      %     for the syntax obj = plotlabeled( 'summary_func', @nanmean );
      
      N = numel( inputs );
      assert( mod(N, 2) == 0, '(field, value) pairs are incomplete' );
      
      if ( N == 0 ), return; end
      
      props = properties( obj );
      
      prop_names = inputs(1:2:end);
      prop_vals = inputs(2:2:end);
      
      cls = class( obj );
      
      for j = 1:numel(prop_names)
        name = prop_names{j};
        
        assert( ischar(name), 'Property name must be char; was "%s".', class(name) );
        assert( ismember(name, props), '"%s" is not a property of class "%s".', name, cls );
        
        obj.(name) = prop_vals{j};
      end
    end
    
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
        assert( ~has_mask(obj), 'Masking with scatter is not yet supported.' );
        
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
      
      %   apply mask, if specified.
      if ( ~strcmp(obj.mask, 'off') )
        keep( data, obj.mask );
      end
      
      assert( size(data, 1) >= 1, 'Data cannot be empty.' );
      
      %   add categories to `data` if any of xcats, groups, or panels is
      %   an empty cell array ({})
      [xcats, groups, panels] = plotlabeled.require_dummy_cats( data, xcats, groups, panels );
      [xcats, groups, panels] = plotlabeled.cell( xcats, groups, panels );
      [xcats, groups, panels] = plotlabeled.uniques( xcats, groups, panels );
      
      specificity = [ xcats(:)', groups(:)', panels(:)' ];
      
      %   ensure all categories exist.
      validate_categories( data, specificity );
      
      if ( obj.prefer_multiple_groups )
        if ( isa(data, 'labeled') )
          tmp_labs = getlabels( data );
        else
          tmp_labs = data;
        end
        
        [groups, panels, xcats] = maybe_redistribute( obj, tmp_labs, groups, panels, xcats );
        specificity = [ xcats(:)', groups(:)', panels(:)' ];
      end
      if ( obj.prefer_multiple_xs )
        if ( isa(data, 'labeled') )
          tmp_labs = getlabels( data );
        else
          tmp_labs = data;
        end
        
        [xcats, panels, groups] = maybe_redistribute( obj, tmp_labs, xcats, panels, groups );
        specificity = [ xcats(:)', groups(:)', panels(:)' ];
      end
      
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
      
      if ( obj.sort_combinations )
        plotlabeled.fcat_sortrows( x_combs );
        plotlabeled.fcat_sortrows( p_combs );
        plotlabeled.fcat_sortrows( g_combs );
      end
      
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
      opts.data = data;
      opts.summary_data = summary_data;
      opts.errors_data = errors_data;
      opts.specificity = specificity;
      opts.I = I;
      opts.C = C;
      
      opts.g_cats = groups;
      opts.p_cats = panels;
      opts.x_cats = xcats;
      
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
    
    function [target_cats, pcats, other_cats] = maybe_redistribute(obj, labels, target_cats, pcats, other_cats)
      
      n_targ = numel( findall(labels, target_cats) );
      
      if ( n_targ > 1 )
        return
      end
      
      non_scalar_pcats = try_find_non_scalar( labels, pcats );
      
      if ( ~isempty(non_scalar_pcats) )
        pcats = setdiff( pcats, non_scalar_pcats );
        target_cats = union( target_cats, non_scalar_pcats );
      else
        non_scalar_other_cats = try_find_non_scalar( labels, other_cats );

        if ( ~isempty(non_scalar_other_cats) )
          target_cats = union( target_cats, non_scalar_other_cats );
          other_cats = setdiff( other_cats, non_scalar_other_cats );
        end        
      end
      
      function cats = try_find_non_scalar(labels, cats)
        n_per_p = cellfun( @(x) numel(findall(labels, x)), cats );
        is_non_scalar = n_per_p > 1;

        if ( any(is_non_scalar) )
          non_scalar_inds = find( is_non_scalar );
          [~, min_ind] = min( n_per_p(non_scalar_inds) );        

          cats = cats(non_scalar_inds(min_ind));
        else
          cats = {};
        end
      end
      
    end
    
    function axs = groupplot(obj, func_name, varargin)
      
      %   GROUPPLOT -- Internal utility to plot grouped, row-vector data.
      
      try
        [data, gp] = plotlabeled.parse_varargin( varargin, 4 );
      catch err
        throw( err );
      end
      
      xcats = gp{1};
      groups = gp{2};
      panels = gp{3};
      
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
          inds_mat(row, col) = full_row_ind;
          
          if ( obj.add_errors )
            errors_mat(row, col) = errors_data(full_row_ind);
          end
        end
        
        switch ( func_name )
          case 'bar'
            if ( obj.add_errors )
              h = plotlabeled.barwitherr( errors_mat, summary_mat );
            else
              h = bar( summary_mat );
            end
          case 'stacked_bar'
            if ( rows(summary_mat) == 1 )
              %   if only one x-combination
              h = bar( [summary_mat; nan(1, size(summary_mat, 2))], 'stacked' );
            else
              h = bar( summary_mat, 'stacked' );
            end
          case 'errorbar'
            if ( size(summary_mat, 1) == 1 )
              repeated = [ summary_mat; summary_mat ];
              repeated_errs = [ errors_mat; errors_mat ];
              
              h = errorbar( ones(size(repeated)), repeated, repeated_errs );
            else
              if ( obj.errorbar_connect_non_nan )
                h = plotlabeled.errorbar_connecting_non_nan( summary_mat, errors_mat );
              else
                h = errorbar( summary_mat, errors_mat );
              end
            end
          otherwise
            error( 'Unrecognized function name "%s".', func_name );
        end
        
        if ( obj.add_fit )
          try
            apply_fit( obj, ax, h, summary_mat );
          catch err
            warning( err.message );
          end
        end
        
        summary_mat(:) = NaN;
        errors_mat(:) = NaN;
        
        if ( obj.per_panel_labels )
          add_per_panel_labels( h, g_labs );
        else
          conditional_add_legend( obj, h, g_labs, i == 1 );
        end
        
        n_ticks = size( summary_mat, 1 );
        
        set( ax, 'xtick', 1:n_ticks );
        
        if ( obj.add_x_tick_labels )
          set( ax, 'xticklabel', x_labs );
          set( ax, 'xticklabelrotation', obj.x_tick_rotation );
        end
        
        if ( strcmp(func_name, 'errorbar') )
          set( ax, 'xlim', [0, n_ticks+1] );
        elseif ( strcmp(func_name, 'stacked_bar') && rows(summary_mat) == 1 )
          set( ax, 'xlim', [0, 2] );
        end
        
        if ( obj.add_points && ~strcmp(func_name, 'stacked_bar') )
          plot_points( obj, ax, h, opts.data, inds_mat, opts.I, color_map );
        end
        
        title( p_labs(i, :) );
        
        axs(i) = ax;
      end
      
      set_lims( obj, axs, 'ylim', get_ylims(obj, axs) );
      
      function add_per_panel_labels(h, g_labs)
        if ( ~obj.add_legend )
          return
        end
        
        if ( ~strcmp(func_name, 'errorbar') )
          return
        end
        
        is_missing_series = arrayfun( @(x) all(columnize(isnan(x.YData))), h );
        
        if ( all(is_missing_series) )
          return
        end
        
        legend( h(~is_missing_series), g_labs(~is_missing_series) );
      end
      
      function apply_fit(obj, ax, hs, summary_mat)
        np = get( ax, 'nextplot' );
        set( ax, 'nextplot', 'add' );

        for idx = 1:size(summary_mat, 2)
          scol = summary_mat(:, idx);
          x_ = 1:numel( scol );
          nan_ind = isnan( scol );
          scol(nan_ind) = [];
          x_(nan_ind) = [];
          
          one_h = plot( ax, x_, obj.fit_func(x_, scol) );
          set( one_h, 'color', get(hs(idx), 'color') );
        end
        
        set( ax, 'nextplot', np );
      end
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
        
        try
          x_offset = get( h, 'xoffset' );
        catch err
          x_offset = 0;
        end
        
        x_data = get( h, 'xdata' );
        
        for j = 1:numel(matching_inds)
          match_ind = matching_inds(j);
          
          if ( isnan(match_ind) )
            continue; 
          end
          
          ind = I{match_ind};
          
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
            
            if ( obj.point_jitter > 0 )
              jitter = (obj.point_jitter/2) - (obj.point_jitter * rand(numel(x_points), 1));
              x_points = x_points + reshape( jitter, size(x_points) );
            end
            
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
    
    function tf = has_mask(obj)
      
      %   HAS_MASK
      
      tf = ~strcmp( obj.mask, 'off' );
    end
    
    function [m, hm] = get_mask(obj, N)
      
      %   GET_MASK
      
      hm = has_mask( obj );
      
      if ( hm )
        m = obj.mask;
      else
        m = 1:N;
      end
    end
    
    function m = get_points_color_map(obj)
      
      %   GET_POINTS_COLOR_MAP 
      
      if ( isempty(obj.points_color_map) )
        m = containers.Map();
      else
        m = obj.points_color_map;
      end
    end
    
    function x = get_x(obj, sz_check)
      
      %   GET_X -- Get x coordinate vector for n-d data.
      
      x = get_xyz( obj, 'x', sz_check );
    end
    
    function y = get_y(obj, sz_check)
      
      %   GET_Y -- Get y coordinate vector for n-d data.
      
      y = get_xyz( obj, 'y', sz_check );
    end
    
    function dat = get_xyz(obj, prop, sz_check)
      
      %   GET_XYZ -- Get vector of x, y, z, ... data to plot against.
      
      dat = obj.(prop);
      
      if ( isempty(dat) )
        dat = 1:sz_check;
      else
        if ( numel(dat) ~= sz_check )
          name = upper( prop );
          error( ['%s data do not correspond to the plotted data. %s data have' ...
            , ' %d value(s); expected %d.'], name, name, numel(dat), sz_check );
        end
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
            , ' %d value(s); plotted data have %d columns.'], numel(obj.x), rows );
        end
        x = repmat( obj.x(:), 1, cols );        
      end
    end
    
    function f = get_figure(obj)
      
      %   GET_FIGURE
      
      if ( isempty(obj.fig) || ~isvalid(obj.fig) )
        f = gcf();
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
    
    function l = get_xlims(obj, axs)
      
      %   GET_XLIMS
      
      l = get_current_lims( obj, 'x_lims', 'match_x_lims', 'xlim', axs );
    end
    
    function l = get_ylims(obj, axs)
      
      %   GET_YLIMS
      
      l = get_current_lims( obj, 'y_lims', 'match_y_lims', 'ylim', axs );
    end
    
    function c = get_clims(obj, axs)
      
      %   GET_CLIMS
      
      c = get_current_lims( obj, 'c_lims', 'match_c_lims', 'clim', axs );      
    end
    
    function r = get_rlims(obj, axs)
      
      %   GET_RLIMS
      
      r = get_current_lims( obj, 'r_lims', 'match_r_lims', 'rlim', axs );
    end
    
    function l = get_current_lims(obj, prop, match_prop, kind, axs)
      
      %   GET_CURRENT_LIMS -- Get matched or manually set limits for axis.
      
      if ( ~isempty(obj.(prop)) )
        l = obj.(prop);
      elseif ( obj.(match_prop) )
        all_lims = get_lims( obj, axs, kind );
        l = [ min(all_lims(:, 1)), max(all_lims(:, 2)) ];
      else
        l = get_lims( obj, axs, kind );
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
          warning( 'Number of subplots (%d) exceeds manually specified shape (%d).' ...
            , n, prod(s) );
          s = plotlabeled.get_subplot_shape( n );
        end
      end
    end
  end
  
  methods (Static = true, Access = public)
    
    %
    %     CREATION
    %
    
    function pl = make_spectrogram(freqs, t)
      
      %   MAKE_SPECTROGRAM -- Instantiate spectrogram configuration.
      %
      %     See also plotlabeled
      %
      %     IN:
      %       - `freqs` (double)
      %       - `t` (double)
      %     OUT:
      %       - `pl` (plotlabeled)
      
      if ( nargin < 2 ), t = []; end
      if ( nargin < 1 ), freqs = []; end
      
      pl = plotlabeled();
      pl.add_smoothing = true;
      pl.smooth_func = @(x) imgaussfilt(x, 2);
      pl.summary_func = @plotlabeled.nanmean;
      pl.x = t;
      pl.y = freqs;
      pl.invert_y = true;
    end
    
    function pl = make_common(varargin)
      
      %   MAKE_COMMON -- Instantiate common configuration.
      %
      %     See also plotlabeled
      %
      %     IN:
      %       - `varargin`
      %     OUT:
      %       - `pl` (plotlabeled)
      
      pl = plotlabeled();
      pl.summary_func = @plotlabeled.nanmean;
      pl.error_func = @plotlabeled.nansem;
      pl.one_legend = true;
      pl.sort_combinations = true;
      
      %   overwrite opts as necessary
      assign_pair_inputs( pl, varargin );
    end
    
    function n = num_category_specifiers(for_function_name)
      
      %   NUM_CATEGORY_SPECIFIERS -- Number of category specifiers for
      %     function.
      %
      %     n = plotlabeled.num_category_specifiers( for_func ); returns
      %     the number of category specifiers that the function uses. 
      %
      %     For example, plotlabeled.bar() requires categories specifiers 
      %     for the x-axis, groups, and panels, and so
      %     plotlabeled.num_category_specifiers( 'bar' ) returns 3.
      %
      %     See also plotlabeled
      
      persistent specifiers;
      
      if ( isempty(specifiers) || ~isvalid(specifiers) )
        specifiers = containers.Map();
        
        specifiers('bar') = 3;
        specifiers('boxplot') = 2;
        specifiers('errorbar') = 3;
        specifiers('hist') = 1;
        specifiers('polarhistogram') = 1;
        specifiers('imagesc') = 1;
        specifiers('lines') = 2;
        specifiers('pie') = 2;
        specifiers('scatter') = 2;
        specifiers('stackedbar') = 3;
        specifiers('violinalt') = 2;
        specifiers('violinplot') = 2;
      end
      
      validateattributes( for_function_name, {'char'}, {}, mfilename, 'function_name' );
      
      if ( ~ismethod('plotlabeled', for_function_name) )
        error( '"%s" is not a plotlabeled plotting function.', for_function_name );
      end
      
      n = specifiers(for_function_name);
    end
    
    %
    %   FIT FUNCS
    %
    
    function y = polyfit_linear(x, y)
      
      %   POLYFIT_LINEAR
      
      y = polyval( polyfit(x(:)', y(:)', 1), x );      
    end
    
    function y = polyfit_quadratic(x, y)
      
      %   POLYFIT_QUADRATIC
      
      y = polyval( polyfit(x(:)', y(:)', 2), x );      
    end
    
    %
    %   SUMMARY FUNCS
    %
    
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
    
    function y = median(x)
      
      %   MEDIAN -- Median across the first dimension.
      
      y = median( x, 1 );
    end
    
    function y = nanmean(x)
      
      %   NANMEAN -- Mean across the first dimension, excluding NaN.
      
      y = nanmean( x, 1 );
    end
    
    function y = nanmedian(x)
      
      %   MEDIAN -- Median across the first dimension, excluding NaN.
      
      y = nanmedian( x, 1 );
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
    
    function y = norm01(x)
      
      %   NORM01 -- Normalize data between 0 and 1, across first dimension.
      %
      %     IN:
      %       - `x` (double) -- Data.
      %     OUT:
      %     - `y` (double) -- Matrix of the same size as `x`.
      
      maxs = max( x, [], 2 );
      mins = min( x, [], 2 );
      
      y = bsxfun( @rdivide, bsxfun(@minus, x, mins), (maxs-mins) );
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
        return
      elseif ( N == 8 )
        shape = [ 2, 4 ];
        return
      end

      n_rows = round( sqrt(N) );
      n_cols = ceil( N/n_rows );
      shape = [ n_rows, n_cols ];
    end
    
    function f = fcat_sortrows(f)
      
      %   FCAT_SORTROWS -- Sort rows of an fcat object.
      %
      %     IN:
      %       - `f` (fcat)
      %     OUT:
      %       - `f` (fcat)
      
      [~, I] = sortrows( categorical(f) );
      keep( f, I );
    end
    
    function shape = try_subplot_shape(shape, N)
      
      %   TRY_SUBPLOT_SHAPE -- Get subplot shape from shape or linear size.
      %
      %     s = ... try_subplot_shape( SHAPE, N ) returns `SHAPE` in `s` if
      %     the product of `SHAPE` has at least `N` elements. Otherwise, it
      %     returns the result of ... `get_subplot_shape( N )`.
      %
      %     IN:
      %       - `shp` (double)
      %       - `N` (double)
      %     OUT:
      %       - `shape` (double)
      
      if ( prod(shape(:)) < N )
        shape = plotlabeled.get_subplot_shape( N );
      end
    end
    
    function [hs, store_stats] = scatter_addcorr(ids, X, Y, alpha, add_text)
      
      %   SCATTER_ADDCORR -- Add correlation + regression lines to scatter plots.
      %
      %     plotlabeled.scatter_addcorr( ids, X, Y ) adds correlation stats 
      %     and fitted lines to each subplot in `ids`. `ids` is a struct 
      %     array as returned from `plotlabeled.scatter`. `X` and `Y` are 
      %     the x and y vectors of data as input to `scatter`.
      %
      %     ... scatter_addcorr( ..., ALPHA ) uses ALPHA to determine
      %     whether the correlation is significant.
      %
      %     h = ... scatter_addcorr(...) returns an array of handles to the
      %     fitted lines.
      %
      %     [..., store_stats] = ... also returns a matrix of [r, p] value
      %     pairs.
      %
      %     IN:
      %       - `ids` (struct array)
      %       - `X` (numeric)
      %       - `Y` (numeric)
      %       - `alpha` (double) |OPTIONAL|
      %     OUT:
      %       - `hs` (array of graphics objects)
      %       - `store_stats` (double)
      
      if ( nargin < 4 ), alpha = 0.05; end
      if ( nargin < 5 ), add_text = true; end

      hs = gobjects( size(ids) );
      store_stats = nan( numel(ids), 2 );

      for i = 1:numel(ids)
        ax = ids(i).axes;
        ind = ids(i).index;

        x = X(ind);
        y = Y(ind);
        
        if ( isempty(x) )
          continue;
        end

        [r, p] = corr( x, y, 'rows', 'complete' );

        xlims = get( ax, 'xlim' );
        xticks = get( ax, 'xtick' );

        ps = polyfit( x, y, 1 );
        y = polyval( ps, xticks );

        cstate = get( ax, 'nextplot' );
        set( ax, 'nextplot', 'add' );
        h = plot( ax, xticks, y );
        set( ax, 'nextplot', cstate );
        
        try
          line_col = unique( ids(i).series.CData, 'rows' );
          assert( size(line_col, 1) == 1 );
          
          set( h, 'Color', line_col );
        catch err
          % ignore color error
        end

        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hs(i) = h;  

        coord_func = @(x) ((x(2)-x(1)) * 0.75) + x(1);

        xc = coord_func( xlims );
        yc = y(end);

        txt = sprintf( 'R = %0.2f, p = %0.3f', r, p);

        if ( p < alpha ), txt = sprintf( '%s *', txt ); end

        if ( add_text )
          text( ax, xc, yc, txt );
        end

        store_stats(i, :) = [ r, p ];
        
        set( ax, 'xlim', xlims );
      end
    end
  end
    
  methods (Static = true, Access = private)
    
    function h = errorbar_connecting_non_nan(summary_mat, errors_mat)
      
      x_mat = nan( size(summary_mat) );
      copy_summary_mat = nan( size(summary_mat) );
      copy_errors_mat = nan( size(errors_mat) );
      
      for i = 1:size(summary_mat, 2)
        non_nans = find( ~isnan(summary_mat(:, i)) );
        num_non_nans = numel( non_nans );
        
        x_mat(1:num_non_nans, i) = non_nans;
        copy_summary_mat(1:num_non_nans, i) = summary_mat(non_nans, i);
        copy_errors_mat(1:num_non_nans, i) = errors_mat(non_nans, i);
      end
      
      h = errorbar( x_mat, copy_summary_mat, copy_errors_mat );
    end
    
    function s = get_identifiers()
      
      %   GET_IDENTIFIERS
      
      s = struct( 'axes', {}, 'series', {}, 'index', {}, 'selectors', {} );
    end
    
    function [data, selectors] = parse_varargin(inputs, low)
      
      %   PARSE_VARARGIN -- Obtain labeled data from labeled object or data
      %     + fcat object.
      
      n_in = numel( inputs );
      
      if ( n_in < low ), error( 'Not enough input arguments.' ); end
      if ( n_in > low+1 ), error( 'Too many input arguments.' ); end
      
      if ( n_in == low )
        data = inputs{1};
        selectors = inputs(2:end);
      else
        data = labeled( inputs{1}, inputs{2} );
        selectors = inputs(3:end);
      end
    end
    
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
      preferred = unique( preferred(:)', 'stable' );
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
    
    function varargout = require_dummy_cats(data, varargin)
      
      %   REQUIRE_DUMMY_CATS -- Add categories if unspecified.
      %
      %     ... require_dummy_cats( data, xcats, groups, panels, ... )
      %     checks if xcats, ... is an empty cell array ({}). If so, a new
      %     dummy category will be added to `data`, and the corresponding
      %     output of this function will be the new category name.
      
      varargout = cell( size(varargin) );
      offset = 1;
      
      for i = 1:numel(varargin)
        cats = varargin{i};
        if ( ~ischar(cats) && isempty(cats) )
          [ varargout{i}, offset ] = require_dummy_category( data, offset );
        else
          varargout{i} = cats;
        end
      end
      
      function [cname, start] = require_dummy_category(data, start)
        pattern = plotlabeled.DUMMY_CATEGORY_PATTERN;
        cname = sprintf( pattern, start );
        while ( hascat(data, cname) )
          start = start + 1;
          cname = sprintf( pattern, start );
        end
        start = start + 1;
        addcat( data, cname );
      end
    end
    
    function varargout = barwitherr(errors,varargin)
      
      %   BARWITHERR -- Plot a bar plot with error bars.
      %
      %     https://www.mathworks.com/matlabcentral/fileexchange/30639-barwitherr-errors-varargin

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
    
    function assert_oneof(data, classes, kind)
      
      %   ASSERT_ONEOF
      
      if ( nargin < 2 ), kind = '(unspecified)'; end
      if ( ~iscell(classes) ), classes = { classes }; end
      
      if ( ~ismember(class(data), classes) )
        error( 'Data of type "%s" must be one of the following classes:\n%s' ...
          , kind, strjoin(classes, ' | ') );
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