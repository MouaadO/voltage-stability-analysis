%% CPF Plot along selected line using simple two-bus model
% Pseudo-arc-length continuation with predictor (tangent) and corrector (Newton)
% visualized on the PV plot. Ignores mesh effects (line-focused analysis).

global BusData LineData selected_line user_inputs analysis_mode

% Validate required data
if isempty(selected_line) || isempty(BusData) || isempty(LineData) || isempty(user_inputs)
    error('Required data not initialized. Please configure the system properly.');
end

% 1) Setup from selected line
from_bus = selected_line(1);
to_bus  = selected_line(2);

% Validate bus indices
if from_bus < 1 || from_bus > size(BusData, 1) || to_bus < 1 || to_bus > size(BusData, 1)
    error('Invalid bus indices: %d, %d', from_bus, to_bus);
end

row = find((LineData(:,1)==from_bus & LineData(:,2)==to_bus) | (LineData(:,1)==to_bus & LineData(:,2)==from_bus), 1, 'first');
if isempty(row)
    error('Selected line %d-%d not found in LineData.', from_bus, to_bus);
end

% Prefer Slack/PV as source
type_from = BusData(from_bus,2); type_to = BusData(to_bus,2);
if (type_from == 0) && (type_to ~= 0)
    src = to_bus; ld = from_bus;
else
    src = from_bus; ld = to_bus;
end

V1 = BusData(src,3);
X  = LineData(row,4);

% Validate parameters
if X <= 0 || ~isfinite(X)
    error('Invalid line reactance X = %g', X);
end
if V1 <= 0 || ~isfinite(V1)
    error('Invalid source voltage V1 = %g', V1);
end

% 2) User inputs: power factor, optional lambda limit and step
if isempty(user_inputs)
    error('CPF requires a power factor value in the input field.');
end
pf = user_inputs(1);
if ~isfinite(pf) || pf <= 0 || pf > 1
    error('PF must be a single scalar in (0,1]. Received: %g', pf);
end
B  = tan(acos(pf)); % Q = B * P

% 3) Continuation parameters and helpers
Pmax_ref = V1^2/(2*X);      % Reference maximum at pf=1
% Theoretical peak factor for given PF (relative to PF=1 reference)
lam_peak = sqrt(1 + B^2) - B;  % P_max(pf) / P_max_ref
% Limit for |lambda|: default well beyond peak to allow full lower branch
if numel(user_inputs) >= 2
    lam_limit = user_inputs(2);
else
    lam_limit = lam_peak + 1.0;
end

ds = 0.03;                  % Arc-length step
if numel(user_inputs) >= 3, ds = user_inputs(3); end
ds_min = 1e-5; ds_max = 0.06;   % allow smaller steps near the nose
max_newton = 50; newton_tol = 1e-10;

% Initial point (lambda=0): no load, V2 ~= V1, delta ~= 0
lam = 0.0; V2  = V1; del = 0.0;

% Storage
lams = lam; V2s = V2; Pvals = 0;
Pdir = Pmax_ref; A = V1/X; % P = lam * Pdir, Q = B*P

% Equation blocks and derivatives
F = @(V2_,d_,lam_) [ A*V2_*sin(d_) - lam_*Pdir;  A*V2_*cos(d_) - (V2_^2)/X - B*lam_*Pdir ];
Fx = @(V2_,d_) [ A*sin(d_),        A*V2_*cos(d_); 
                 A*cos(d_) - 2*V2_/X,  -A*V2_*sin(d_) ];
Flam = [-Pdir; -B*Pdir];

% Compute initial tangent (orientation-free; will align after first step)
Jx = Fx(V2,del);
xprime = -Jx\Flam;           % one tangent with lambda' = 1
tan_vec = [xprime; 1];
tan_vec = tan_vec / norm(tan_vec);

% Prepare figure and plotting handles
try
    figure('Name','CPF - Courbe PV (2-bus)','Color','w','NumberTitle','off');
    hold on; grid on; box on;
    h_curve = plot(Pvals, V2s, 'm-', 'LineWidth', 2, 'DisplayName', sprintf('CPF PF=%.2f', pf));
    h_pred = plot(nan, nan, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Predictor');
    h_corr = plot(nan, nan, 'g-',  'LineWidth', 1.2, 'DisplayName', 'Corrector');
    xlabel('Puissance Active P (pu)');
    ylabel(sprintf('Tension V_{%d} (pu)', ld));
    title(sprintf('CPF le long de la ligne %d-%d', from_bus, to_bus));
catch ME
    error('Failed to create figure: %s', ME.message);
end

% Continuation loop
% Accumulators for drawing all predictor/corrector segments
predX = []; predY = [];
corrX = []; corrY = [];
for stepIdx = 1:3000
    if abs(lam) >= lam_limit, break; end

    % Predictor along tangent
    z = [V2; del; lam];
    z_pred = z + ds * tan_vec;          % predictor
    V2p = z_pred(1); delp = z_pred(2); lamp = z_pred(3);

    % Corrector: Newton on augmented system [F(x,λ); t^T (z - z_pred)] = 0
    ok = false; V2k = V2p; delk = delp; lamk = lamp;
    for it = 1:max_newton
        % Build residual
        rF = F(V2k, delk, lamk);
        rC = tan_vec.' * ([V2k; delk; lamk] - z_pred);
        R = [rF; rC];
        if norm(R,inf) < newton_tol
            ok = true; break;
        end
        % Jacobian of augmented system
        Jx = Fx(V2k, delk);
        Jg = [ Jx,  Flam;  tan_vec.' ];
        % Solve update
        delta = -Jg\R;
        V2k = V2k + delta(1);
        delk = delk + delta(2);
        lamk = lamk + delta(3);
        if ~isfinite(V2k) || ~isfinite(delk) || ~isfinite(lamk)
            ok = false; break;
        end
    end

    if ok && isreal(V2k) && V2k > 0
        % Accept step and append
        V2 = V2k; del = delk; lam = lamk;
        lams(end+1,1) = lam; %#ok<AGROW>
        V2s(end+1,1)  = V2;  %#ok<AGROW>
        Pvals(end+1,1)= lam*Pdir; %#ok<AGROW>
        set(h_curve, 'XData', Pvals, 'YData', V2s);
        % Plot predictor and corrector segments (accumulate for all steps)
        P_now = Pvals(end-1); V_now = V2s(end-1);
        P_pred = lamp*Pdir;   V_pred = V2p;
        P_corr = Pvals(end);  V_corr = V2s(end);
        predX = [predX, P_now, P_pred, NaN]; %#ok<AGROW>
        predY = [predY, V_now, V_pred, NaN]; %#ok<AGROW>
        corrX = [corrX, P_pred, P_corr, NaN]; %#ok<AGROW>
        corrY = [corrY, V_pred, V_corr, NaN]; %#ok<AGROW>
        set(h_pred, 'XData', predX, 'YData', predY);
        set(h_corr, 'XData', corrX, 'YData', corrY);
        
        % Safe drawnow with error handling
        try
            drawnow limitrate;
        catch
            % Ignore drawing errors and continue
        end

        % Update tangent at accepted point
        Jx = Fx(V2,del);
        xprime = -Jx\Flam;  % one tangent with lambda' = 1
        tan_next = [xprime; 1];
        tan_next = tan_next / norm(tan_next);
        % Align tangent with actual movement direction via dot product
        move_vec = [V2 - V2s(end-1); del - z(2); lam - lams(end-1)];
        if dot(tan_next, move_vec) < 0
            tan_next = -tan_next;
        end
        tan_vec = tan_next;
        % Step adaptation
        ds = min(ds*1.1, ds_max);
    else
        % Reduce step and try again from current point
        ds = ds/2;
        if ds < ds_min
            break; % cannot proceed further (very near singularity)
        end
        continue;
    end
end

% Finalize plot
legend('show','Location','SouthWest');
plot(Pvals(end), V2s(end), 'ro', 'MarkerFaceColor','r', 'HandleVisibility','off');
text(Pvals(end), V2s(end), '  dernier point', 'Color','r');

