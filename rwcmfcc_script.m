setting.arch = 'mfcc';

%% This loop in computed in the cluster
% nBatches = 45;
% for batch_id = 1:nBatches
%     compute_batch(batch_id, setting);
% end

%%
features = load_features(setting);

%%
average_distances = compute_average_distances(features);