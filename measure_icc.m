function icc = measure_icc(features)
%% Compute the centroid of each instrument
nFeatures = size(features(1).data, 1);
nInstruments = length(unique([features.instrument_id]));
instruments = cell(1, nInstruments);
centroids = zeros(nFeatures, nInstruments);
for instrument_id = 1:nInstruments
    instrument = features([features.instrument_id] == instrument_id);
    centroids(:, instrument_id) = mean([instrument.data], 2);
    instruments{instrument_id} = instrument;
end

%% Compute the inter-class variance
interclass_variance = sum(var(centroids, [], 2));

%% Compute the variance across samples
global_variance = sum(var([features.data], [], 2));

%% Return Fisher's Intra-class Correlation Coefficient (ICC)
icc = interclass_variance / global_variance;
end