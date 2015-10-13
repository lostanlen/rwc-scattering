function [coeff, Xmean, explained] = compute_pca(setting)
% Load features (with their metadata)
features = load_features(setting);

% Load data
X = [features.data].';

% Compute PCA
[coeff, score, latent, tsquared, explained, Xmean] = pca(X);

% Generate savefile name
prefix = ['PCA_', setting2prefix(setting)];

% Get host name
pcinfo = java.net.InetAddress.getLocalHost();
host = pcinfo.getHostName(); % class is java.lang.String
host = char(host); % convert to MATLAB char array

% Get date
date = datestr(now());

% Save
if ~exist('PCAs', 'dir')
    mkdir('PCAs');
end
savefile_path = ['PCAs/', savefile_name];
save(savefile_path, 'coeff', 'Xmean', 'explained');

% Print termination message
disp('--------------------------------------------------------------------------------');
disp(['Finished PCA on host ', host,' at ', date,' with settings:']);
disp(setting);
disp(['Elapsed time is ', elapsed_str, ' seconds.']);
end
