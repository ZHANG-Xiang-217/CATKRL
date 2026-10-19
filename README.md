# CATKRL (**C**lustering **A**lignment-based **T**ransfer on **K**ernel **R**einforcement **L**earning)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23111290.svg)](https://doi.org/10.5281/zenodo.23111290)

## Contents
- [Overview](#overview)
- [Repo Contents](#repo-contents)
- [System Requirements](#system-requirements)
- [Usage](#usage)
- [Data](#data)
- [Citation](#citation)
- [License](#license)

# Overview
This repository provides the MATLAB code and a minimal dataset for the manuscript

> **Aligning Neural Population Patterns Facilitates Motor Learning Transfer**
> Xiang Zhang, Zhiwei Song, Xiang Shen, Shuhang Chen, Yifan Huang, José C. Príncipe, and Yiwen Wang

CATKRL is a neural decoding framework that models motor learning transfer by aligning action-specific neural clusters across tasks in a low-dimensional feature space. Neural patterns are projected by PCA and jPCA, clustered by DBSCAN, and the most similar clusters of the two tasks are aligned by iterative closest point (ICP). A clustering kernel reinforcement learning decoder then reuses the neural-action mapping learned in the first task to decode the aligned patterns of the second task.

# Repo Contents

- [data](./data): Simulated neurons (Fig. 3) and two recorded sessions of rat 025 (R2 in the manuscript)
- [alignment](./alignment): PCA + jPCA projection, DBSCAN clustering and ICP alignment
- [decoding](./decoding): Clustering kernel reinforcement learning decoder and the AGREL baseline
- [training](./training): Training schedule, decoder training and held-out testing
- [draw_figures](./draw_figures): Scripts to plot results
- [utils](./utils): Settings (`opt_Setup_*.m`) and supporting functions
- [results](./results): Outputs (the folder is created automatically when a demo runs)
- `main_simu.m`: Simulated neurons of Fig. 3
- `main_real.m`: CATKRL on the recorded data of rat 025

# System Requirements

## Hardware requirements
A standard computer with enough RAM for in-memory operations. Both demos run in under one minute on an Intel Core i9-14900 workstation.

## Software requirements

### OS requirements
The code was tested on Windows 11. It should also run on macOS and Linux.

### Dependencies
`MATLAB R2024a` (earlier releases that support `xline`, `yline` and `movmean` with `'Endpoints'` should also work) and the following toolbox:

- [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html)

# Usage

Run both scripts from the repository root.

## Simulation demo
- Run `main_simu.m`.
    - Loads the simulated spike counts in `data/simulation.mat` and draws Fig. 3: tuning curves of the three neurons (a), the neural patterns with the linear feature plane (b), and the patterns in the 2-D feature space (c).
    - Prints the mean and SD of each neuron for each action, and the rotation of the Rest-to-Press direction between the two tasks (87.5°).
    - Results are saved in `results/simulation_results.mat`.
- The simulation settings are in `utils/opt_Setup_simu.m`: rounded Gaussian spike counts, SD 4 except the Press-high-lever cluster (SD 8 along neuron 2 in task 1 and along neuron 1 in task 2), 500 samples per action and 1,000 Rest samples in task 2. Set `opt.regenerate = true` to simulate the data again.

## Real-data demo
- Run `main_real.m`.
    - Aligns the two-lever session of rat 025 to the one-lever session and trains three decoders in the order one-lever → two-lever → one-lever: AGREL, clustering KRL without alignment, and CATKRL (clustering KRL on the aligned two-lever patterns).
    - Tests each decoder on held-out trial segments (20% of each session) at the end of one-lever training, 200 samples after the switch to the two-lever task (initial transfer), at the end of two-lever training, on the one-lever task right after two-lever training (memory), and 200 samples after returning to the one-lever task.
    - Plots the alignment, the learning curves and the held-out success rates. Results are saved in `results/rat025_results.mat`.
- Settings are in `utils/opt_Setup_real.m`:
    - `opt.repeatTime`: number of repeats with different splits and training orders (5 by default; 20 in the manuscript).
    - `opt.useSavedFeatures`: `true` decodes the jPCA coordinates used for the results in the manuscript (`data/rat025_jpca_features.mat`); `false` recomputes the coordinates from the binned spike counts.
    - `opt.alignmentData`: `'all'` estimates the alignment from all patterns of both sessions, as for the results in the manuscript (label-free, but the held-out patterns are included); `'train'` estimates it from the training patterns only.
- With the default settings the demo prints:

```
Held-out success rate, mean (SD) over 5 repeats
                                                 AGREL    Clustering KRL            CATKRL
One-lever, end of training                0.736 (0.016)      0.725 (0.029)      0.723 (0.023)
Two-lever, initial transfer               0.499 (0.142)      0.597 (0.023)      0.663 (0.038)
Two-lever, end of training                0.894 (0.014)      0.870 (0.028)      0.890 (0.017)
One-lever, memory after two-lever         0.386 (0.038)      0.349 (0.070)      0.393 (0.020)
One-lever, after retraining               0.582 (0.038)      0.582 (0.037)      0.669 (0.051)
```

These values come from one animal and five repeats; the statistics in the manuscript are computed across six rats.

## Implementing on new datasets
Preprocess each session into the format of `data/rat025_one_lever.mat` (spike counts of each channel in the reference bin and the preceding bins, one column per neural pattern, and the action label of each pattern), set the channels, bins, DBSCAN radii and decoder parameters in `utils/opt_Setup_real.m`, and run `main_real.m` with `opt.useSavedFeatures = false`.

# Data

| File | Contents |
| --- | --- |
| `data/simulation.mat` | `spike{task}`: samples × 3 simulated spike counts; `label{task}`: action of each sample (1 Rest, 2 Press high lever, 3 Press low lever); `settings`: simulation settings |
| `data/rat025_one_lever.mat` | One-lever session (`session`). `spike`: 192 × 2300 spike counts per 100-ms bin, rows ordered channel + 32 × bin (32 channels; bin 0 is the reference bin and bins 1–5 precede it); `label`: action of each pattern (1 Rest, 2 Press); `responseTime`: response time (s) of the trial of each pattern; `tapNum`: number of preceding bins |
| `data/rat025_two_lever.mat` | Two-lever session, 192 × 2470 patterns, same fields (labels 1 Rest, 2 Press high lever, 3 Press low lever) |
| `data/rat025_jpca_features.mat` | jPCA coordinates (5 dimensions) and labels of the two sessions used for the decoding results in the manuscript |

Neural activity was recorded from 16 channels in the primary motor cortex and 16 channels in the medial prefrontal cortex. Each trial contributes 5 Rest and 5 Press patterns at −400, −300, −200, −100 and 0 ms relative to the event; consecutive groups of 5 patterns therefore share time bins and are kept on the same side of the train/test split.

The complete dataset is available from the corresponding author upon reasonable request for research purposes.

# Citation

If you use this repository, please cite the manuscript and the archived repository. Citation metadata are provided in [`CITATION.cff`](CITATION.cff).

> Zhang, X., Song, Z., Shen, X., Chen, S., Huang, Y., Príncipe, J. C. & Wang, Y. Aligning Neural Population Patterns Facilitates Motor Learning Transfer. Zenodo https://doi.org/10.5281/zenodo.23111290 (2026).

The DOI above resolves to the latest archived version. Each release also has its own version-specific DOI, listed on the Zenodo record.

# License

Code is released under the [MIT License](LICENSE). Data in `data/` are released under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

Contact: Xiang Zhang (repository maintainer) and Yiwen Wang (corresponding author).
