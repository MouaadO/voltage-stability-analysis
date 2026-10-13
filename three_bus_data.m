%% EXAMPLE 1 - SYSTEME SIMPLE (3 NOEUDS)
% Ce fichier contient les donn�es exactes du TP pour l'Exemple 1

global BusData LineData Sbase

%% ============================================================================
%                         PARAM�TRES G�N�RAUX
%% ============================================================================
Sbase = 100;        % Base de puissance (MVA)
f = 60;             % Fr�quence (Hz)

%% ============================================================================
%                    DONN�ES DES N�UDS (BUS DATA)
%% ============================================================================
% Column 1: Bus Number
% Column 2: Type (3=Slack, 2=PV, 0=PQ)
% Column 3: V (pu) - Voltage Magnitude
% Column 4: Angle (degrees)
% Column 5: P_load (pu)
% Column 6: Q_load (pu)
% Column 7: P_gen (pu)
% Column 8: Q_gen (pu)
% Column 9: Shunt B (pu)

BusData = [
    % Bus   Type   V      Angle   P_load  Q_load  P_gen   Q_gen   ShuntB
    1       3      1.0    0.0     0.0     0.0     0.0     0.0     0.0   % Infinite Bus
    2       2      1.0007 0.0     0.0     0.0     0.9     0.0     0.0   % Generator (Source V1)
    3       0      1.0    0.0     0.5     0.3     0.0     0.0     0.0   % Load (Target V2)
];

%% ============================================================================
%              DONN�ES DES LIGNES (LINE DATA)
%% ============================================================================
% Column 1: From Bus
% Column 2: To Bus
% Column 3: R (pu)
% Column 4: X (pu)
% Column 5: B (pu) - Line Charging
% Column 6: Tap Ratio (0 if line)

LineData = [
    % From  To   R       X     B       Tap
    1       2    0.012   0.3   0.066   0
    2       3    0.012   0.3   0.066   0  % This is the critical line for stability (Gen -> Load)
];