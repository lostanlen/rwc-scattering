setting.arch = 'joint';
setting.Q = 12;

nBatches = 45;
for batch_id = 1:nBatches
    compute_batch(batch_id, setting);
end

%%
features = load_features(setting, 'max');

%%
summary = compute_average_distances(setting, features)