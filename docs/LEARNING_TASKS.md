# Learning tasks: from the first run to your own experiment

Eight tasks, each building on the previous one. Do them in order. Each task says **what to do**, **what to look
at**, the **questions to answer** and what to **hand in**. Keep everything in one logbook (a Word file or
notebook): commands you ran, the machine and its price, numbers, figures and your answers.

| # | Task | Where | Time | Cost |
|---|---|---|---|---|
| 0 | Accounts and reading | laptop | 1 h | – |
| 1 | First run on Vast.ai | Vast.ai | 1 h | ~$0.10 |
| 2 | Look inside one mission | Vast.ai | 1–2 h | ~$0.20 |
| 3 | Find your way in the code | GitHub (browser) | 1–2 h | – |
| 4 | Baseline versus one change | Vast.ai | 1 h | ~$0.15 |
| 5 | Sweep the tilt limit | Vast.ai | 1–2 h | ~$0.25 |
| 6 | Gusts, seeds and the disturbance observer | Vast.ai | 1–2 h | ~$0.30 |
| 7 | AirSim check | Vast.ai (GPU) | 1–2 h | ~$0.30 |
| 8 | Your own experiment | Vast.ai | 1 week | ~$1 |

You can do Tasks 2, 4, 5 and 6 in **one** Vast.ai session to save start-up time — but destroy the machine
whenever you stop for more than an hour.

---

## Task 0 — Accounts and reading
1. Create a free GitHub account; open the repository and read `README.md`.
2. Create a Vast.ai account and add $5–10 credit (no automatic top-up).
3. Read [VAST_AI_GUIDE.md](VAST_AI_GUIDE.md) Part A from start to end **before** renting anything.
4. Read [EXPERIMENTS.md](EXPERIMENTS.md) sections 1–3.

**Questions.** (a) What does each of the three planners know about the wind? (b) What is the difference
between a *refused* mission and a *failed* one? (c) Why is "energy per parcel delivered" fairer than "mean energy
of successful missions"?

**Hand in:** your three answers (a few lines each).

---

## Task 1 — First run on Vast.ai
Follow VAST_AI_GUIDE Part A steps 1–8 exactly: rent, run `quick.yaml`, run `summarise.py`, download the zip,
**destroy**.

**Look at:** `summary.csv` and `success_rate.png`.

**Questions.** (a) How many workers did the run use (first line of the output) and how long did the 12 missions take?
Estimate how long `thesis_full.yaml` (1,536 missions) would take on the same machine. (b) In the quick test
(12 m/s), which planner delivered every parcel? (c) What did the session cost (Billing page)?

**Hand in:** the two figures, the summary table and your answers. Confirm that the instance is destroyed.

---

## Task 2 — Look inside one mission
On a new instance, fly these four missions and open each picture in `results/single/`:

```bash
cd ~/quadrotor-wind-corridors/sim
python3 fly_one.py --U 12 --theta 180 --planner wind     --controller dob
python3 fly_one.py --U 12 --theta 180 --planner shortest --controller dob
python3 fly_one.py --U 16 --theta 0   --planner shortest --controller pid
python3 fly_one.py --U 16 --theta 0   --planner wind     --controller dob
```

**Look at:** the route over the city, the wind arrows, where the tracking error grows, the energy curve and the
chosen cruise height and speed (printed as `z_out`, `z_back`, `v_out`, `v_back`).

**Questions.**
(a) Wind toward 180° blows from east to west. On which leg (out to the customer or back to the depot) is it a
headwind? How does the wind-aware planner's route or height differ from the shortest path?
(b) In the third mission, at what time and where does the drone fail, and why on that leg?
(c) The fourth mission is refused. The steady tilt needed to hold ground speed against a headwind is
tan φ = |F_aero| / (m g). Use it to explain why the planner refuses, and why the *empty* drone on the return is
more at risk than the loaded drone on the way out.

**Hand in:** the four pictures and your answers (half a page).

---

## Task 3 — Find your way in the code
No machine needed: browse the code on GitHub. Find and write down **the file and line** of:
1. the usable battery energy, and how it is computed;
2. the 35° tilt limit of the wind-aware planner;
3. the candidate cruise heights and speeds of the energy planners;
4. the rule that decides whether a mission counts as `success`;
5. the moment the parcel is released and the mass drops;
6. the power-law wind profile above the roofs.

Then read `configs/template_all_options.yaml` and match each of the six items to a config setting (where one
exists).

**Hand in:** a table *item — file:line — config setting*.

---

## Task 4 — Baseline versus one change
```bash
python3 run_experiments.py --config ../configs/baseline_small.yaml
python3 run_experiments.py --config ../configs/heavy_parcel.yaml
python3 summarise.py ../results/experiments/baseline_small/campaign.csv \
                     ../results/experiments/heavy_parcel/campaign.csv --out ../results/experiments/compare_payload
```

**Questions.** (a) Write down your prediction **before** you look at the results: with a 1.0 kg parcel, will the
wind-aware planner refuse more or fewer missions? Will energy per parcel rise by more or less than the mass
ratio (2.6 / 2.2 = 18 %)? (b) Was your prediction right? Quote the numbers. (c) Name one reason the result could
be different in a real city.

**Hand in:** prediction, figures, one paragraph of results with numbers.

---

## Task 5 — Sweep the tilt limit
The tilt limit trades refusals (missions not attempted) against in-flight failures. Make four configs and run
them as one batch:

```bash
cd ~/quadrotor-wind-corridors/configs
for t in 25 30 35 40; do
  sed "s/^name: .*/name: tilt_$t/; s/TILT_LIMIT: .*/TILT_LIMIT: $t/" tilt_limit_30.yaml > tilt_$t.yaml
done
cd ../sim
tmux new -s tilt          # optional, see VAST_AI_GUIDE B3
bash run_batch.sh ../configs/tilt_25.yaml ../configs/tilt_30.yaml ../configs/tilt_35.yaml ../configs/tilt_40.yaml
```

**Look at:** `refused_pct` and `failed_in_flight_pct` in the batch `summary.csv`.

**Questions.** (a) Draw (by hand or in Excel) refused % and failed % against the tilt limit, at 12 and 16 m/s.
(b) Which limit would you recommend to an operator and why? (c) Is 16 missions per limit enough to be sure?
What would you add to the grid?

**Hand in:** the plot, your recommendation, your answer to (c).

---

## Task 6 — Gusts, seeds and the disturbance observer
```bash
python3 run_experiments.py --config ../configs/strong_gusts.yaml --dry-run   # 288 missions
python3 run_experiments.py --config ../configs/strong_gusts.yaml             # use 32 cores (~10-15 min)
python3 summarise.py ../results/experiments/strong_gusts/campaign.csv
```
Then compare PID with PID+DOB in Python:
```python
import pandas as pd
d = pd.read_csv("../results/experiments/strong_gusts/campaign.csv")
print(d[~d.rejected].groupby(["U_ref", "controller"]).rms_err.mean().unstack())
print(d.groupby(["U_ref", "controller"]).success.mean().unstack())
```

**Questions.** (a) By how much does the observer reduce the RMS error in gusty air, and is that more or less
than in the dissertation (55–67 %)? (b) Does it change the success rate? Why might lower error *not* mean more
deliveries? (c) How much do the results change between seeds 0, 1 and 2?

**Hand in:** the two tables and your answers.

---

## Task 7 — AirSim check
Rent a machine with a **GPU** (8 GB+). Then:
```bash
start_airsim
cd ~/quadrotor-wind-corridors/sim
python3 airsim_replay.py --one
cat ../results/airsim/airsim_summary.csv
stop_airsim
```
Download `results/airsim/` (zip it first) and look at the frames in `frames_U12_th0_wind/`.

**Questions.** (a) Did the mission complete? Compare the RMS and maximum tracking error with the same mission in
the Python simulator (`fly_one.py --U 12 --theta 0 --planner wind --controller pid`). (b) Name two differences
between the two simulators that could explain the gap. (c) Why is an independent simulator a useful check,
even though its map does not contain our city?

**Hand in:** the summary row, three frames and your answers. See [AIRSIM.md](AIRSIM.md) if something fails.

---

## Task 8 — Your own experiment
Design, run and report one experiment of your own. Some ideas (pick one, or propose your own):
- **Suburb versus city centre:** `wind: alpha: 0.20` (suburb) against 0.30 (city).
- **Stronger corridors:** `wind: k_corridor: 0.5` — do avenues help or hurt?
- **Smaller battery:** `vehicle: battery_Wh` 40 instead of 59.2 — where does the battery become the limit?
- **New customers:** add customer positions (in streets!) with `planner: CUSTOMERS` and check them with `fly_one.py`.
- **Faster cruise options:** `planner: SPEEDS: [6, 8, 10, 12, 14]`.

Write a one-page report in this structure:
1. **Hypothesis** — one sentence, with a number that would confirm or reject it.
2. **Variables** — what you change, what you keep fixed, what you measure.
3. **Config** — the YAML file (paste it) and the number of missions.
4. **Results** — one table and one figure from `summarise.py`.
5. **Interpretation** — supported or rejected? Why, physically?
6. **Limitations** — what could make the result wrong (model, grid size, seeds)?

**Hand in:** the report, your config file and the `summary.csv`. Discuss with your supervisor whether it can go
into the dissertation (for example as an extension in the discussion chapter).

---

## Good habits
- Predict first, then run. Write the prediction down.
- One change at a time; same grid as the baseline.
- Give every experiment its own `name`, and keep the config with the results (the runner copies it for you).
- Download results before you destroy the machine. Destroy the machine every time.
- If something fails, copy the **last 20 lines** of the output into your logbook and send them with your question.
