%% Settings
setting.arch = 'plain';
setting.Q = 16;

%% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');
nBatches = length(unique([file_metas.batch_id]));

%% This loop is computed in the cluster
for batch_id = 1:nBatches
    compute_batch(batch_id, file_metas, setting);
end

%% Load features and max-pool across time
features = load_features(setting, 'max');

%% 
summary = compute_average_distances(setting, features, 'euclidean');
summary = compute_average_distances(setting, features, 'cosine');

%% This loop is computed in the cluster
Bs = 2.^(1:8);
newsetting = setting;
for B = Bs
    disp(B);
    for batch_id = 1:nBatches
        poolfreq_batch(batch_id, setting, B);
    end
    newsetting.F = F;
    features = load_features(newsetting, 'max');
    summary = compute_average_distances(newsetting, features, 'euclidean');
    summary = compute_average_distances(newsetting, features, 'cosine');
end