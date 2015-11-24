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
Fs = 2.^(1:8);
newsetting = setting;
for F = Fs
    disp(F);
    for batch_id = 1:nBatches
        blurfreq_batch(batch_id, setting, F);
    end
    newsetting = setting;
    newsetting.F = F;
    features = load_features(newsetting, 'max');
    summary = compute_average_distances(newsetting, features, 'euclidean');
    summary = compute_average_distances(newsetting, features, 'cosine');
end