function icc = measure_icc(features)
mus = logspace(-6,6);
nMus = length(mus);
uniformlog_iccs = zeros(1, nMus);

for mu_index = 1:nMus
    %% Load log-features
    mu = mus(mu_index);
    [features.logdata] = log1p([features.data] / mu);
    
    %% Compute the centroid of each instrument
    nFeatures = size(features(1).data, 1);
    nInstruments = length(unique([features.instrument_id]));
    instruments = cell(1, nInstruments);
    centroids = zeros(nFeatures, nInstruments);
    for instrument_id = 1:nInstruments
        instrument = features([features.instrument_id] == instrument_id);
        centroids(:, instrument_id) = mean([instrument.logdata], 2);
        instruments{instrument_id} = instrument;
    end
    
    %% Compute the inter-class variance
    interclass_variance = sum(var(centroids, [], 2));
    
    %% Compute the variance across samples
    global_variance = sum(var([features.logdata], [], 2));
    
    %% Return Fisher's Intra-class Correlation Coefficient (ICC)
    uniformlog_iccs(mu_index) = interclass_variance / global_variance;
end

etas = logspace(-2, 2, 9);
nEtas = length(etas);
medianlog_iccs = zeros(1, nEtas);
feature_medians = max(median(max([features.data], 0), 2), eps());
[features.mediandata] = ...
    bsxfun(@rdivide, max([features.data], 0), feature_medians);

for eta_index = 1:nEtas
    %% Load log-features
    eta = etas(eta_index);
    [features.mediandata] = log1p([features.mediandata] / eta);
    
    %% Compute the centroid of each instrument
    nFeatures = size(features(1).data, 1);
    nInstruments = length(unique([features.instrument_id]));
    instruments = cell(1, nInstruments);
    centroids = zeros(nFeatures, nInstruments);
    for instrument_id = 1:nInstruments
        instrument = features([features.instrument_id] == instrument_id);
        centroids(:, instrument_id) = mean([instrument.logdata], 2);
        instruments{instrument_id} = instrument;
    end
    
    %% Compute the inter-class variance
    interclass_variance = sum(var(centroids, [], 2));
    
    %% Compute the variance across samples
    global_variance = sum(var([features.data], [], 2));
    
    %% Return Fisher's Intra-class Correlation Coefficient (ICC)
    medianlog_iccs(eta_index) = interclass_variance / global_variance;
end

icc.uniformlog_iccs = uniformlog_iccs;
icc.medianlog_iccs = medianlog_iccs;
icc.best_icc = max(max(uniformlog_iccs), max(medianlog_iccs));
end