%% Calculation_Script
% Handles both PV (Eq 10) and QV (Eq 12/13) analysis logic.

global BusData LineData selected_system user_inputs analysis_mode selected_line

%% 1. SYSTEM SETUP with Error Handling
% =========================================================================

% Validate global variables are set
if isempty(selected_line) || isempty(BusData) || isempty(LineData)
    error('Required data not initialized. Please select a system and line.');
end

if numel(selected_line) < 2
    error('Invalid line selection.');
end

% Use user-selected line; validate exists
from_bus = selected_line(1);
to_bus   = selected_line(2);

% Validate bus indices
if from_bus < 1 || from_bus > size(BusData, 1) || to_bus < 1 || to_bus > size(BusData, 1)
    error('Invalid bus indices: %d, %d', from_bus, to_bus);
end

line_row = find((LineData(:,1)==from_bus & LineData(:,2)==to_bus) | ...
                (LineData(:,1)==to_bus   & LineData(:,2)==from_bus));

% Validate line found
if isempty(line_row)
    error('Line %d-%d not found in LineData', from_bus, to_bus);
end

% Pick source/load orientation: prefer Slack/PV as source if present
type_from = BusData(from_bus, 2);
type_to   = BusData(to_bus, 2);
if (type_from == 0) && (type_to ~= 0)
    bus_source_idx = to_bus;
    bus_load_idx   = from_bus;
else
    bus_source_idx = from_bus;
    bus_load_idx   = to_bus;
end

V1 = BusData(bus_source_idx, 3);
X  = LineData(line_row, 4);

% Validate critical parameters
if X <= 0 || ~isfinite(X)
    error('Invalid line reactance X = %g', X);
end
if V1 <= 0 || ~isfinite(V1)
    error('Invalid source voltage V1 = %g', V1);
end

% Title helper: always reflect the chosen line
sys_name = sprintf('Ligne %d-%d', from_bus, to_bus);

%% 2. PV CURVE LOGIC
% =========================================================================
if strcmp(analysis_mode, 'PV')
    
    fp_values = user_inputs; % Input is list of Power Factors
    
    % Validate power factors
    if any(fp_values <= 0) || any(fp_values > 1)
        error('Power factors must be in range (0, 1]. Invalid values detected.');
    end
    
    P_limit_theoretical = V1^2 / (2*X);
    P_range = linspace(0, P_limit_theoretical * 1.5, 1000);
    
    critical_points = [];
    
    % Create one figure with all power factors
    try
        figure('Name', 'Courbes PV', 'Color', 'w', 'NumberTitle', 'off');
        hold on; grid on; box on;
    catch ME
        error('Failed to create figure: %s', ME.message);
    end

    for i = 1:length(fp_values)
        pf = fp_values(i);
        B = tan(acos(pf)); % Q = B*P
        
        V2_high = nan(size(P_range));
        V2_low  = nan(size(P_range));
        
        for j = 1:length(P_range)
            P = P_range(j);
            discriminant = (V1^4)/4 - P*X*(P*X + B*V1^2);
            
            if discriminant >= 0
                term_common = (V1^2)/2 - B*P*X;
                root_delta = sqrt(discriminant);
                V2_high(j) = sqrt(term_common + root_delta);
                V2_low(j)  = sqrt(term_common - root_delta);
            else
                break; % Collapse - no more valid points
            end
        end
        
        % Only plot if we have valid points
        valid_high = ~isnan(V2_high);
        valid_low = ~isnan(V2_low);
        
        if any(valid_high)
            % Plotting with different colors for each power factor
            color_map = lines(length(fp_values));
            plot(P_range(valid_high), V2_high(valid_high), '-', 'LineWidth', 2, ...
                'Color', color_map(i,:), 'DisplayName', sprintf('FP=%.2f', pf));
            if any(valid_low)
                plot(P_range(valid_low), V2_low(valid_low), '--', 'LineWidth', 1.5, ...
                    'Color', color_map(i,:), 'HandleVisibility', 'off');
            end
            
            % Save Critical Point
            idx = find(valid_high, 1, 'last');
            if ~isempty(idx)
                critical_points = [critical_points; pf, P_range(idx), V2_high(idx)];
                plot(P_range(idx), V2_high(idx), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'HandleVisibility', 'off');
            end
        else
            warning('No valid points for PF=%.2f. Power factor may be too low for this system.', pf);
        end
    end
    
    title(['Courbes PV - ' sys_name]);
    xlabel('Puissance Active P (pu)', 'FontWeight', 'bold');
    ylabel(['Tension V_{' num2str(bus_load_idx) '} (pu)'], 'FontWeight', 'bold');
    legend('show', 'Location', 'SouthWest');
    ylim([0 1.2]);
    
    % Display critical points coordinates
    if ~isempty(critical_points)
        fprintf('\n=== Points Critiques PV ===\n');
        fprintf('FP\t\tP_max (pu)\tV_critique (pu)\n');
        fprintf('-----------------------------------------------\n');
        for k = 1:size(critical_points, 1)
            fprintf('%.2f\t\t%.4f\t\t%.4f\n', critical_points(k,1), critical_points(k,2), critical_points(k,3));
        end
        fprintf('-----------------------------------------------\n\n');
    end
    
%% 3. QV CURVE LOGIC (UPDATED)
% =========================================================================
elseif strcmp(analysis_mode, 'QV')
    
    % Input represents ratios of P/Pmax (e.g., 0.5, 0.75, 1.0)
    p_ratios = user_inputs; 
    
    % Validate power ratios
    if any(p_ratios < 0) || any(p_ratios > 2)
        warning('Some P/Pmax values are outside typical range [0, 2].');
    end
    
    % Theoretical Max Power at PF=1 for reference
    P_max_ref = V1^2 / (2*X); 
    
    % Voltage Range for X-axis
    V_range = linspace(0.1, 1.5, 500);
    
    % Store critical points for the locus line
    qv_critical_locus = [];
    
    % Create one figure with all power ratios
    try
        figure('Name', 'Courbes QV', 'Color', 'w', 'NumberTitle', 'off');
        hold on; grid on; box on;
    catch ME
        error('Failed to create figure: %s', ME.message);
    end
    
    fprintf('\n=== Points Critiques QV ===\n');
    fprintf('P/Pmax\t\tV_critique (pu)\tQ_critique (pu)\n');
    fprintf('-----------------------------------------------\n');
    
    for i = 1:length(p_ratios)
        ratio = p_ratios(i);
        P_target = ratio * P_max_ref; 
        
        Q_curve = nan(size(V_range));
        
        for j = 1:length(V_range)
            V2 = V_range(j);
            
            % Eq 12 derivation: 
            sin_theta = (P_target * X) / (V1 * V2);
            
            if abs(sin_theta) <= 1
                cos_theta = sqrt(1 - sin_theta^2);
                
                % Standard Eq 11 gives the parabola opening DOWN (Hill)
                Q_calc = (V1 * V2 * cos_theta - V2^2) / X;
                
                % FLIP SIGN TO MATCH PDF FIGURE 4 (Valley Shape)
                % This represents Reactive Power Injection Required
                Q_curve(j) = -Q_calc; 
            else
                Q_curve(j) = NaN;
            end
        end
        
        % Plot Curve in blue
        plot(V_range, Q_curve, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('P = %.2f P_{max}', ratio));
            
        % FIND CRITICAL POINT (Minimum of the "Valley")
        [min_Q, idx_min] = min(Q_curve);
        if ~isnan(min_Q)
             % Plot the dot
             plot(V_range(idx_min), min_Q, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'HandleVisibility', 'off');
             % Store for Locus Line
             qv_critical_locus = [qv_critical_locus; V_range(idx_min), min_Q];
             
             % Display critical point coordinates
             fprintf('%.2f\t\t%.4f\t\t%.4f\n', ratio, V_range(idx_min), min_Q);
        end
    end
    
    fprintf('-----------------------------------------------\n\n');
    
    % Draw Q=0 axis
    plot([min(V_range) max(V_range)], [0 0], 'k--', 'LineWidth', 1, 'HandleVisibility', 'off');
    
    title(['Courbes QV - ' sys_name]);
    xlabel(['Tension V_{' num2str(bus_load_idx) '} (pu)'], 'FontWeight', 'bold');
    ylabel('Injection Q requise (pu)', 'FontWeight', 'bold');
    legend('show', 'Location', 'NorthEast');
    
    % Corrected stability regions for the U-shape
    % Right side of the U is stable (slope > 0)
    % Left side of the U is unstable (slope < 0)
    ylim_vals = ylim;
    text(0.3, ylim_vals(2)*0.8, 'Instable', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
    text(1.2, ylim_vals(2)*0.8, 'Stable', 'Color', 'g', 'FontSize', 10, 'FontWeight', 'bold');
    

end