# Voltage Stability Analysis

An interactive MATLAB application for exploring voltage stability using P-V curves, Q-V curves and continuation power flow. Select a line from a three-bus or fourteen-bus example and examine how power factor and loading affect voltage.

## Tools used

MATLAB, MATLAB graphics, numerical linear algebra and a predictor-corrector continuation algorithm.

## How to run

1. Open this folder as the MATLAB current folder.
2. Run `voltage_stability_app`.
3. Select the system, line and analysis type, then enter the requested parameters.
4. Inspect voltage curves, critical points and continuation steps.

## Files

| File | Purpose |
| --- | --- |
| `voltage_stability_app.m` | Interactive application and input selection |
| `plot_pv_qv_curves.m` | P-V and Q-V analysis |
| `plot_continuation_power_flow.m` | Predictor-corrector continuation |
| `three_bus_data.m`, `fourteen_bus_data.m` | Example network data |

## Limitations

The supplied continuation implementation uses a simplified two-bus equivalent for the selected line. It ignores meshed-network effects and is not a full multi-bus continuation solver. The report discusses a broader context; the source code defines the implementation.

## Project context

Prepared from academic project files. Collaborative work remains team work; personal names are omitted from this public copy. Original technical comments and interfaces may be in French. No new license has been assigned.

## Technical report

[Read the original French technical report](docs/voltage-stability-analysis-report.pdf). Personal names and document metadata were removed from this copy. Technical content is preserved and may describe earlier study settings.

## Verification status

Source structure and reference names were inspected. MATLAB startup did not complete in this environment, so MATLAB and Simulink execution could not be verified.
