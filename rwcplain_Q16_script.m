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
summary = compute_average_distances(setting, features, 'euclidean');
summary = compute_average_distances(setting, features, 'cosine');

%% This loop is computed in the cluster
Bs = 2.^(1:8);
newsetting = setting;
for B = Bs
    disp(B);
    newsetting.B = B;
    features = load_features(newsetting, 'max');
    disp('Measuring ICC');tic()
    icc = measure_icc(features);
    disp(icc);
    toc();
    prefix = setting2prefix(newsetting);
    save([prefix, '/', prefix, '_icc'], 'icc');
end