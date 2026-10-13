# Voltage Stability Analysis

A MATLAB application for exploring how loading and power factor affect voltage in an electrical network. It brings together P-V curves, Q-V curves and continuation power flow in an interactive interface.

## What it does

- Selects lines from three-bus and fourteen-bus network examples.
- Plots voltage against active power and reactive-power requirements.
- Identifies critical operating points and traces the continuation curve.

## Results

Figures from the [technical report](docs/voltage-stability-analysis-report.pdf).

### P-V curves

The curves compare different power factors and mark the critical loading points.

![P-V curves for different power factors](docs/results/pv-curves.png)

### Q-V curves

Reactive-power requirements are shown for several active-power levels.

![Q-V curves](docs/results/qv-curves.png)

### Continuation power flow

![Continuation curve with predictor and corrector steps](docs/results/continuation-curve.png)

## Tools

MATLAB, MATLAB graphics and numerical linear algebra.

## Run

Open this folder in MATLAB and run:

```matlab
voltage_stability_app
```

Choose the system, line and analysis type, then enter the operating parameters.

## Project files

| File | Purpose |
| --- | --- |
| `voltage_stability_app.m` | Interactive application |
| `plot_pv_qv_curves.m` | P-V and Q-V calculations and plots |
| `plot_continuation_power_flow.m` | Predictor-corrector continuation |
| `three_bus_data.m`, `fourteen_bus_data.m` | Example network data |

Developed as a collaborative academic engineering project.
