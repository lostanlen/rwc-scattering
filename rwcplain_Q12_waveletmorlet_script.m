setting.arch = 'plain';
setting.Q = 12;
setting.wavelet = 'morlet';

%% This loop in computed in the cluster
% nBatches = 45;
% for batch_id = 1:nBatches
%     compute_batch(batch_id, setting);
% end

%%
features = load_features(setting);
