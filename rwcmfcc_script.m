%% Settings
setting.arch = 'mfcc';

%% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');
nBatches = length(unique([file_metas.batch_id]));

%% This loop in computed in the cluster
numceps = [40, 23, 11, 3, 1];
for numcep = numceps
    setting.numcep = numcep;
    for batch_id = 1:nBatches
        compute_batch(batch_id, file_metas, setting);
    end
end

%% Load features and max-pool across time
features = load_features(setting, 'max');

%% Measure distances
summary = compute_average_distances(setting, features, 'euclidean');
summary = compute_average_distances(setting, features, 'cosine');
