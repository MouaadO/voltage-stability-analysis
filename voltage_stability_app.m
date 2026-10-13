function voltage_stability_app()
    % Main Interface for Voltage Stability Analysis
% Academic team project; personal names omitted in the public copy.

    % 1. voltage_stability_app FIGURE
    fig = figure('Name', 'TP RE3 Analyse de la stabilité de tension', ...
        'NumberTitle', 'off', ...
        'Position', [100, 100, 900, 600], ...
        'Color', [0.94 0.94 0.94], ...
        'MenuBar', 'none', ...
        'Resize', 'off');

    % Global variables to share data between panels
    global selected_system user_inputs analysis_mode selected_line
    
    % Initialize global variables to prevent crashes
    selected_system = 1;
    user_inputs = [];
    analysis_mode = '';
    selected_line = [];

    % =====================================================================
    % PANEL 1: WELCOME SCREEN
    % =====================================================================
    p_welcome = uipanel(fig, 'Units', 'normalized', 'Position', [0 0 1 1], ...
        'BackgroundColor', 'white', 'Tag', 'p_welcome');

    % Department title
    uicontrol(p_welcome, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.75 0.8 0.08], 'String', 'Département d''électrotechnique', ...
        'FontSize', 18, 'FontWeight', 'bold', 'BackgroundColor', 'white');

    % Main title
    uicontrol(p_welcome, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.65 0.8 0.08], 'String', 'Commande et Stabilité des Réseaux Electriques', ...
        'FontSize', 18, 'FontWeight', 'bold', 'BackgroundColor', 'white');

    % Academic year
    uicontrol(p_welcome, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.55 0.8 0.06], 'String', 'Année universitaire 2025/2026', ...
        'FontSize', 14, 'BackgroundColor', 'white');

    % Authors
    uicontrol(p_welcome, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.45 0.8 0.06], ...
        'String', 'Academic team project', ...
        'FontSize', 13, 'BackgroundColor', 'white');

    % Supervisor
    uicontrol(p_welcome, 'Style', 'text', 'Units', 'normalized', ...
% Academic coursework.
        'FontSize', 13, 'BackgroundColor', 'white');

    % Partie 1 button
    uicontrol(p_welcome, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.35 0.20 0.3 0.08], ...
        'String', 'Démarrer l''analyse', 'FontSize', 12, 'FontWeight', 'normal', ...
        'BackgroundColor', [0.94 0.94 0.94], 'ForegroundColor', 'black', ...
        'Callback', {@nav_to_type_select, fig});

    % Exit button
    uicontrol(p_welcome, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.35 0.10 0.3 0.08], ...
        'String', 'Exit', 'FontSize', 12, 'FontWeight', 'normal', ...
        'BackgroundColor', [0.94 0.94 0.94], 'ForegroundColor', 'black', ...
        'Callback', 'close all');



    % =====================================================================
    % PANEL 3: TYPE SELECTION (PV vs QV)
    % =====================================================================
    p_type = uipanel(fig, 'Units', 'normalized', 'Position', [0 0 1 1], ...
        'Visible', 'off', 'BackgroundColor', [0.94 0.94 0.94], 'Tag', 'p_type');

    uicontrol(p_type, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.8 0.8 0.1], 'String', 'TYPE DE COURBE', ...
        'FontSize', 16, 'FontWeight', 'bold', 'BackgroundColor', [0.94 0.94 0.94]);

    uicontrol(p_type, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.25 0.5 0.5 0.15], 'String', 'Courbes PV', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'Callback', {@nav_to_setup, fig, 'PV'});

    uicontrol(p_type, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.25 0.3 0.5 0.15], 'String', 'Courbes QV', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'Callback', {@nav_to_setup, fig, 'QV'});

    uicontrol(p_type, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.25 0.1 0.5 0.15], 'String', 'CPF (Continuation Power Flow)', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'Callback', {@nav_to_setup, fig, 'CPF'});

    uicontrol(p_type, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.05 0.05 0.15 0.08], 'String', '< RETOUR', ...
        'Callback', {@nav_back, fig, 'p_welcome'});

    % =====================================================================
    % PANEL 4: SETUP & EXECUTION (Dynamic for PV/QV)
    % =====================================================================
    p_setup = uipanel(fig, 'Units', 'normalized', 'Position', [0 0 1 1], ...
        'Visible', 'off', 'BackgroundColor', 'white', 'Tag', 'p_setup');

    % Header Title (Dynamic)
    h_title = uicontrol(p_setup, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.85 0.8 0.1], 'String', 'CONFIGURATION', ...
        'FontSize', 16, 'FontWeight', 'bold', 'Tag', 'lbl_title', ...
        'BackgroundColor', 'white');

    % System Selection Group
    bg_sys = uibuttongroup(p_setup, 'Title', 'Choix du Systéme', ...
        'Units', 'normalized', 'Position', [0.2 0.55 0.6 0.25], ...
        'BackgroundColor', 'white', 'Tag', 'bg_sys');
    
    uicontrol(bg_sys, 'Style', 'radiobutton', 'String', 'Example 1', ...
        'Units', 'normalized', 'Position', [0.1 0.6 0.8 0.3], 'Tag', '1', ...
        'BackgroundColor', 'white', 'FontSize', 11);
    
    uicontrol(bg_sys, 'Style', 'radiobutton', 'String', 'Example 2', ...
        'Units', 'normalized', 'Position', [0.1 0.2 0.8 0.3], 'Tag', '2', ...
        'BackgroundColor', 'white', 'FontSize', 11);

    % Update line list when system selection changes
    set(bg_sys, 'SelectionChangedFcn', {@on_system_changed, fig});
    


    % Input Field Label (Dynamic)
    uicontrol(p_setup, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.2 0.45 0.6 0.05], 'String', 'Paramètres:', ...
        'FontWeight', 'bold', 'Tag', 'lbl_input', 'BackgroundColor', 'white');

    % Input Edit Box
    uicontrol(p_setup, 'Style', 'edit', 'Units', 'normalized', ...
        'Position', [0.2 0.35 0.6 0.08], 'String', '', ...
        'Tag', 'ed_input', 'FontSize', 11, 'BackgroundColor', 'white');

    % Line selection label
    uicontrol(p_setup, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.2 0.29 0.6 0.05], 'String', 'Choisir la ligne :', ...
        'FontWeight', 'bold', 'BackgroundColor', 'white');

    % Line selection dropdown
    uicontrol(p_setup, 'Style', 'popupmenu', 'Units', 'normalized', ...
        'Position', [0.2 0.22 0.6 0.06], 'String', {''}, ...
        'Tag', 'pop_line', 'FontSize', 11, 'BackgroundColor', 'white', ...
        'Callback', {@on_line_changed, fig});

    % Line info label (auto-updated)
    uicontrol(p_setup, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.2 0.165 0.6 0.04], 'String', '', ...
        'Tag', 'lbl_lineinfo', 'FontSize', 10, 'ForegroundColor', [0.2 0.2 0.2], ...
        'BackgroundColor', 'white', 'HorizontalAlignment', 'left');

    % Run Button (lowered for more spacing)
    uicontrol(p_setup, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.35 0.06 0.3 0.09], 'String', 'Exécuter', ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.5 0.5 0.5], 'ForegroundColor', 'white', ...
        'Callback', {@run_calc, fig});

    uicontrol(p_setup, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.05 0.05 0.15 0.08], 'String', '< RETOUR', ...
        'Callback', {@nav_back, fig, 'p_type'});

end

% =========================================================================
% CALLBACK FUNCTIONS
% =========================================================================

function nav_to_type_select(~, ~, fig)
    set(findobj(fig, 'Tag', 'p_welcome'), 'Visible', 'off');
    set(findobj(fig, 'Tag', 'p_type'), 'Visible', 'on');
end

function nav_to_setup(~, ~, fig, type)
    global analysis_mode
    analysis_mode = type;
    
    p_type = findobj(fig, 'Tag', 'p_type');
    p_setup = findobj(fig, 'Tag', 'p_setup');
    
    set(p_type, 'Visible', 'off');
    set(p_setup, 'Visible', 'on');
    
    % Customize Labels based on Type
    lbl_title = findobj(p_setup, 'Tag', 'lbl_title');
    lbl_input = findobj(p_setup, 'Tag', 'lbl_input');
    ed_input = findobj(p_setup, 'Tag', 'ed_input');
    
    if strcmp(type, 'PV')
        set(lbl_title, 'String', 'COURBE PV');
        set(lbl_input, 'String', 'Choix des facteurs de puissance :');
        set(ed_input, 'String', '1 0.9 0.8 0.7 0.6');
    elseif strcmp(type, 'QV')
        set(lbl_title, 'String', 'COURBE QV');
        set(lbl_input, 'String', 'Choix de P/Pmax:');
        set(ed_input, 'String', '1 0.9 0.8 0.7 0.6');
    else
        set(lbl_title, 'String', 'CPF (Continuation Power Flow)');
        set(lbl_input, 'String', 'Facteur de puissance (unique):');
        set(ed_input, 'String', '0.9');
    end

    % Populate line choices for current selected system
    bg_sys = findobj(fig, 'Tag', 'bg_sys');
    sel = get(bg_sys, 'SelectedObject');
    if isempty(sel)
        % Default to Example 1 if nothing selected by MATLAB
        set(bg_sys, 'SelectedObject', findobj(bg_sys, 'Tag', '1'));
        sys_id = 1;
    else
        sys_id = str2double(get(sel, 'Tag'));
    end
    refresh_line_list(fig, sys_id);
end

function nav_back(~, ~, fig, target_tag)
    % Hide all, show target
    panels = findobj(fig, 'Type', 'uipanel');
    set(panels, 'Visible', 'off');
    set(findobj(fig, 'Tag', target_tag), 'Visible', 'on');
end

function run_calc(~, ~, fig)
    global selected_system user_inputs selected_line analysis_mode
    
    % 1. Get System
    bg_sys = findobj(fig, 'Tag', 'bg_sys');
    sel = get(bg_sys, 'SelectedObject');
    selected_system = str2double(get(sel, 'Tag'));
    
    % 2. Get Inputs - Safe parsing with validation
    ed_input = findobj(fig, 'Tag', 'ed_input');
    input_str = get(ed_input, 'String');
    
    % Safe conversion: split by spaces and convert each value
    try
        input_parts = strsplit(strtrim(input_str));
        user_inputs = zeros(1, length(input_parts));
        for k = 1:length(input_parts)
            user_inputs(k) = str2double(input_parts{k});
        end
        % Check for NaN values
        if any(isnan(user_inputs))
            error('Invalid numeric input');
        end
    catch
        errordlg('Veuillez entrer des valeurs numériques valides (séparées par des espaces).', 'Erreur');
        return;
    end
    
    if isempty(user_inputs)
        errordlg('Veuillez entrer des valeurs valides.', 'Erreur');
        return;
    end
    % CPF expects a single PF value only
    if strcmpi(analysis_mode, 'CPF')
        if numel(user_inputs) ~= 1
            errordlg('CPF requiert un seul PF (0 < PF ≤ 1).', 'Erreur');
            return;
        end
        pf_val = user_inputs(1);
        if ~isfinite(pf_val) || pf_val <= 0 || pf_val > 1
            errordlg('PF invalide. Entrez un PF dans (0, 1].', 'Erreur');
            return;
        end
    end
    
    % 3. Load Data
    try
        if selected_system == 1
            three_bus_data;
        else
            fourteen_bus_data;
        end
        
        % Validate that data was loaded correctly
        if ~exist('LineData', 'var') || isempty(LineData)
            error('LineData not loaded properly');
        end
        if ~exist('BusData', 'var') || isempty(BusData)
            error('BusData not loaded properly');
        end
    catch ME
        errordlg(['Erreur lors du chargement des données: ' ME.message], 'Erreur');
        return;
    end
    
    % 4. Read selected line from dropdown
    pop_line = findobj(fig, 'Tag', 'pop_line');
    items = get(pop_line, 'String');
    if ischar(items)
        items = cellstr(items);
    end
    if isempty(items) || isempty(items{1})
        errordlg('Aucune ligne disponible. Veuillez choisir un système.', 'Erreur');
        return;
    end
    idx = get(pop_line, 'Value');
    choice = items{idx};
    nums = sscanf(choice, '%d - %d');
    from_bus = nums(1); to_bus = nums(2);

    selected_line = [from_bus, to_bus];

    % 5. Execute Calculation Script with error handling
    try
        if strcmp(get(findobj(findobj(fig,'Tag','p_setup'),'Tag','lbl_title'),'String'),'CPF (Continuation Power Flow)') || strcmpi(analysis_mode,'CPF')
            plot_continuation_power_flow;
        else
            plot_pv_qv_curves;
        end
    catch ME
        errordlg(['Erreur lors du calcul: ' ME.message], 'Erreur de calcul');
        fprintf('\n=== ERREUR DÉTAILLÉE ===\n');
        fprintf('Message: %s\n', ME.message);
        fprintf('Fichier: %s\n', ME.stack(1).file);
        fprintf('Ligne: %d\n', ME.stack(1).line);
        fprintf('========================\n\n');
    end
end

function on_system_changed(~, event, fig)
    % Update selected system and refresh the line list when user toggles Example 1/2
    global selected_system
    selected_system = str2double(get(event.NewValue, 'Tag'));
    refresh_line_list(fig, selected_system);
end

function refresh_line_list(fig, sys_id)
    % Load data for the selected system and populate the line dropdown
    global LineData
    if isempty(sys_id) || isnan(sys_id)
        return;
    end
    try
        if sys_id == 1
            three_bus_data;
        else
            fourteen_bus_data;
        end
        
        % Validate data loaded
        if ~exist('LineData', 'var') || isempty(LineData)
            error('Failed to load LineData');
        end
    catch ME
        warning('Error loading system data: %s', ME.message);
        return;
    end
    pop_line = findobj(fig, 'Tag', 'pop_line');
    if isempty(pop_line)
        return;
    end
    pairs = LineData(:,1:2);
    n = size(pairs,1);
    listItems = cell(n,1);
    for k = 1:n
        listItems{k} = sprintf('%d - %d', pairs(k,1), pairs(k,2));
    end
    set(pop_line, 'String', listItems, 'Value', 1);
    % Update info for the first line
    update_line_info(fig);
end

function on_line_changed(~, ~, fig)
    % Update the line information label when dropdown changes
    update_line_info(fig);
end

function update_line_info(fig)
    % Compose and show human-readable information about the selected line
    global LineData BusData
    pop = findobj(fig, 'Tag', 'pop_line');
    lbl = findobj(fig, 'Tag', 'lbl_lineinfo');
    if isempty(pop) || isempty(lbl)
        return;
    end
    items = get(pop, 'String');
    if isempty(items)
        set(lbl, 'String', '');
        return;
    end
    if ischar(items)
        items = cellstr(items);
    end
    idx = get(pop, 'Value');
    choice = items{idx};
    nums = sscanf(choice, '%d - %d');
    if numel(nums) < 2
        set(lbl, 'String', '');
        return;
    end
    i = nums(1); j = nums(2);
    % Find line row regardless of direction
    row = find((LineData(:,1)==i & LineData(:,2)==j) | (LineData(:,1)==j & LineData(:,2)==i), 1, 'first');
    if isempty(row)
        set(lbl, 'String', '');
        return;
    end
    R = LineData(row,3); X = LineData(row,4); B = LineData(row,5); Tap = LineData(row,6);
    tf = BusData(i,2); tt = BusData(j,2);
    typeName = @(t) ternary(t==3,'Slack', ternary(t==2,'PV', ternary(t==0,'PQ', 'Type?')));
    info = sprintf('Ligne %d-%d  |  R=%.4f, X=%.4f, B=%.4f, Tap=%.3g  |  Bus %d:%s, Bus %d:%s', ...
                   i, j, R, X, B, Tap, i, typeName(tf), j, typeName(tt));
    set(lbl, 'String', info);
end

function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end