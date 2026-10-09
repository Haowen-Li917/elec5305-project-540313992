# ELEC5305 Project — Adaptive Noise Tracking for Speech Enhancement

## Research question

How does the adaptation rate of an STFT noise power spectral density (PSD) estimator affect its ability to follow changing background noise, and what trade-off does faster tracking create between noise reduction and speech preservation?

This project studies a focused parameter trade-off in a conventional STFT/Wiener speech-enhancement pipeline. The contribution is a controlled evaluation of the noise-estimator smoothing factor alpha, not a claim to invent Wiener filtering.

## Experimental plan

The recursive noise estimate is updated on frames classified as noise-only:

`P̂_n(k,m) = α P̂_n(k,m−1) + (1−α)|Y(k,m)|²`

Lower alpha reacts faster; higher alpha smooths more but can lag after a noise change.

- **Baseline:** fixed exponential PSD smoothing, alpha = 0.98, VAD gating, and a Wiener gain.
- **Sweep:** alpha = 0.80, 0.90, 0.95, 0.98, 0.995; keep all other settings and input signals fixed.
- **Controls:** stationary noise; step-changing noise with speech absent near the change; and a step during active speech. Compare VAD-gated and ungated updates to expose speech leakage.
- **Primary measures:** noise-PSD relative RMSE where the noise reference is known; frames to recover within 10% of a new noise level; clean-speech energy retained; and residual-noise energy.
- **Speech-quality measures:** STOI and segmental SNR on paired clean/noisy/enhanced speech. PESQ is optional and only appropriate if implementation and bandwidth match its specification.
- **Recorded speech:** planned paired evaluation using [VoiceBank+DEMAND](https://datashare.ed.ac.uk/handle/10283/2791), subject to confirming access and license terms. Synthetic step noise remains the controlled test for tracking delay.

## Preliminary result — synthetic pilot only

A deterministic single-frequency-bin pilot was run in MATLAB R2024a with 1,200 frames, stepwise noise power of 1.0, 2.5, then 0.6, two speech-active intervals, oracle activity labels, and seed 540313992. It used a Wiener amplitude gain from current noisy power and estimated noise PSD.

| alpha | Noise PSD relative RMSE ↓ | Speech energy retained ↑ | Noise energy remaining ↓ |
|---:|---:|---:|---:|
| 0.80 | 36.180% | 30.141% | 31.259% |
| 0.95 | 37.309% | 24.590% | 26.031% |
| **0.98 (baseline)** | 51.074% | 22.271% | **23.939%** |
| 0.995 | 64.297% | 23.208% | 25.489% |

Lower alpha tracked the imposed changes more closely in this pilot, while alpha = 0.98 left less noise during speech-active frames but retained less clean-speech energy. These are preliminary results from a simplified synthetic model, not perceptual scores or real-recording results. The model uses one frequency bin, one seed, and oracle activity labels; it does not implement an STFT, practical VAD, or the planned corpus. The MATLAB script was executed successfully; the full experiment remains to be done. See [experiment/pilot_alpha_sweep.m](experiment/pilot_alpha_sweep.m) to reproduce the pilot.

## Reproduce the pilot

1. Use MATLAB R2024a or later.
2. From the repository root run: `run('experiment/pilot_alpha_sweep.m')`.
3. The script prints the four metrics for each alpha; no audio file or toolbox is required.
4. For the full experiment, record MATLAB release, audio files, sample rate, STFT window/hop, VAD settings, noise-change times, and random seeds. Keep speech and noise separate for reference metrics.

## Limitations

The pilot does not establish that any setting sounds better. The full study will use STFT frames, a fixed VAD for the alpha sweep, stationary and changing-noise controls, and clean/noisy/enhanced metrics. An oracle-VAD condition will help distinguish estimator behavior from VAD errors. Conclusions will be limited to tested noises, clips, SNRs, and alpha values.

## References

1. R. Martin, “Noise power spectral density estimation based on optimal smoothing and minimum statistics,” *IEEE Transactions on Speech and Audio Processing*, 2001. [DOI](https://doi.org/10.1109/89.928915).
2. Y. Ephraim and D. Malah, “Speech enhancement using a minimum-mean square error short-time spectral amplitude estimator,” *IEEE Transactions on Acoustics, Speech, and Signal Processing*, 1984. [DOI](https://doi.org/10.1109/TASSP.1984.1164453).
3. C. Valentini-Botinhao, [VoiceBank+DEMAND dataset record](https://datashare.ed.ac.uk/handle/10283/2791), University of Edinburgh DataShare.
4. C. H. Taal et al., “An algorithm for intelligibility prediction of time-frequency weighted noisy speech,” *IEEE/ACM Transactions on Audio, Speech, and Language Processing*, 2011. [STOI DOI](https://doi.org/10.1109/TASL.2011.2114881).
5. [ITU-T Recommendation P.862 (PESQ)](https://www.itu.int/itu-t/recommendations/rec.aspx?id=5374&lang=en), scoped to narrow-band telephone networks and codecs.
6. [GitHub Pages publishing source documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).

## Software

- MATLAB R2024a or later (the synthetic pilot has no toolbox dependency)

## Project Proposal

The [project website](https://haowen-li917.github.io/elec5305-project-540313992/) contains the project summary and preliminary pilot. The original [proposal PDF](ELEC5305_Project_Proposal_Haowen_Li.pdf) is retained unchanged.

- [MATLAB pilot](experiment/pilot_alpha_sweep.m)
- [GitHub Pages workflow](.github/workflows/pages.yml)

## Student

**Course:** ELEC5305 Acoustics, Speech and Signal Processing  
**Student ID:** 540313992
