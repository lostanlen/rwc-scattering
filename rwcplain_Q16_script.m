%% Settings
setting.arch = 'plain';
setting.Q = 16;

%% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');

%% This loop is computed in the cluster
nBatches = length(unique([file_metas.batch_id]));
for batch_id = 1:nBatches
    compute_batch(batch_id, file_metas, setting);
end

%% Load features and max-pool across time
features = load_features(setting, 'max');

%% 
summary = compute_average_distances(setting, features, 'euclidean');
summary = compute_average_distances(setting, features, 'cosine');

%% This loop is computed in the cluster
F = 2;
for batch_id = 1:nBatches
    setting.F = F;
    blurfreq_batch(batch_id, file_metas, setting);
end