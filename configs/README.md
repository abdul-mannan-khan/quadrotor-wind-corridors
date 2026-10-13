# Experiment configs

| File | Missions | Purpose |
|---|---|---|
| `quick.yaml` | 12 | smoke test |
| `baseline_small.yaml` | 48 | reference for comparisons (default model) |
| `heavy_parcel.yaml` | 48 | parcel 1.0 kg instead of 0.6 kg |
| `tilt_limit_30.yaml` | 16 | wind-aware planner with a 30° tilt limit |
| `strong_gusts.yaml` | 288 | gustier air, three seeds |
| `thesis_full.yaml` | 1,536 | the dissertation campaign |
| `template_all_options.yaml` | – | every setting with its default value: copy and edit |

Run: `cd sim && python3 run_experiments.py --config ../configs/<file>.yaml`.
How to write your own: [docs/EXPERIMENTS.md](../docs/EXPERIMENTS.md).
