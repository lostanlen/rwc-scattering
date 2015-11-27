function icc = measure_icc(features)
mus = logspace(-6,6);
nMus = length(mus);
uniformlog_iccs = zeros(1, nMus);
nFiles = length(features);
nFeatures = size(features(1).data, 1);
nInstruments = length(unique([features.instrument_id]));

for mu_index = 1:nMus
    %% Load log-features
    mu = mus(mu_index);
    for file_index = 1:length(features)
        features(file_index).logdata = ...
            log1p(features(file_index).data / mu);
    end
    
    %% Compute the centroid of each instrument
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
for file_index = 1:nFiles
    features.data(file_index) = ...
        bsxfun(@rdivide, max([features.data], 0), feature_medians);
end

for eta_index = 1:nEtas
    %% Load log-features
    eta = etas(eta_index);
    for file_index = 1:nFiles
        features(file_index).mediandata = ...
            log1p(features(file_index).mediandata / eta);
    end
    
    %% Compute the centroid of each instrument
    instruments = cell(1, nInstruments);
    centroids = zeros(nFeatures, nInstruments);
    for instrument_id = 1:nInstruments
        instrument = features([features.instrument_id] == instrument_id);
        centroids(:, instrument_id) = mean([instrument.mediandata], 2);
        instruments{instrument_id} = instrument;
    end
    
    %% Compute the inter-class variance
    interclass_variance = sum(var(centroids, [], 2));
    
    %% Compute the variance across samples
    global_variance = sum(var([features.mediandata], [], 2));
    
    %% Return Fisher's Intra-class Correlation Coefficient (ICC)
    medianlog_iccs(eta_index) = interclass_variance / global_variance;
end

icc.uniformlog_iccs = uniformlog_iccs;
icc.medianlog_iccs = medianlog_iccs;
icc.best_icc = max(max(uniformlog_iccs), max(medianlog_iccs));
end