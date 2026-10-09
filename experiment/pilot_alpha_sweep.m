% Deterministic one-bin pilot for the noise-estimator alpha trade-off.
% Synthetic preliminary model only: no STFT, recorded speech, or practical VAD.
% Run from the repository root with:
%   run('experiment/pilot_alpha_sweep.m')

clear; clc;
nFrames = 1200;
speechPower = 0.9;
state = 540313992; % LCG seed; integer arithmetic is exact in double precision.
noisePower = zeros(nFrames, 1);
speechActive = false(nFrames, 1);
observedPower = zeros(nFrames, 1);

for m = 1:nFrames
    if m <= 400
        noisePower(m) = 1.0;
    elseif m <= 800
        noisePower(m) = 2.5;
    else
        noisePower(m) = 0.6;
    end
    speechActive(m) = (m >= 301 && m <= 500) || (m >= 651 && m <= 850);
    [noiseReal, state] = nextGaussian(state);
    [noiseImag, state] = nextGaussian(state);
    speechReal = 0; speechImag = 0;
    if speechActive(m)
        [speechReal, state] = nextGaussian(state);
        [speechImag, state] = nextGaussian(state);
    end
    yReal = noiseReal * sqrt(noisePower(m) / 2) + speechReal * sqrt(speechPower / 2);
    yImag = noiseImag * sqrt(noisePower(m) / 2) + speechImag * sqrt(speechPower / 2);
    observedPower(m) = yReal^2 + yImag^2;
end

alphas = [0.80, 0.95, 0.98, 0.995];
relativePsdRmsePct = zeros(size(alphas));
speechRetainedPct = zeros(size(alphas));
noiseRemainingPct = zeros(size(alphas));
for a = 1:numel(alphas)
    alpha = alphas(a); estimate = 1.0;
    squaredRelativeError = 0; noiseOnlyCount = 0;
    retainedSpeech = 0; totalSpeech = 0;
    residualNoise = 0; totalNoiseDuringSpeech = 0;
    for m = 1:nFrames
        if speechActive(m)
            gainPower = max(0, (observedPower(m) - estimate) / (observedPower(m) + eps));
            retainedSpeech = retainedSpeech + gainPower^2 * speechPower;
            totalSpeech = totalSpeech + speechPower;
            residualNoise = residualNoise + gainPower^2 * noisePower(m);
            totalNoiseDuringSpeech = totalNoiseDuringSpeech + noisePower(m);
        else
            squaredRelativeError = squaredRelativeError + ((estimate - noisePower(m)) / noisePower(m))^2;
            noiseOnlyCount = noiseOnlyCount + 1;
            estimate = alpha * estimate + (1 - alpha) * observedPower(m);
        end
    end
    relativePsdRmsePct(a) = 100 * sqrt(squaredRelativeError / noiseOnlyCount);
    speechRetainedPct(a) = 100 * retainedSpeech / totalSpeech;
    noiseRemainingPct(a) = 100 * residualNoise / totalNoiseDuringSpeech;
end

results = table(alphas(:), relativePsdRmsePct(:), speechRetainedPct(:), ...
    noiseRemainingPct(:), 'VariableNames', ...
    {'Alpha', 'NoisePsdRelativeRmsePercent', ...
    'SpeechEnergyRetainedPercent', 'NoiseEnergyRemainingPercent'});
disp(results);

function [g, state] = nextGaussian(state)
    [u1, state] = nextUniform(state);
    [u2, state] = nextUniform(state);
    u1 = max(u1, 1e-12);
    g = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
end

function [u, state] = nextUniform(state)
    state = mod(1664525 * state + 1013904223, 2^32);
    u = state / 2^32;
end
