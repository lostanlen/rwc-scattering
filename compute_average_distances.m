function [summary,features] = compute_average_distances(setting, features, dist)
if nargin < 3
    dist = 'euclidean';
end

%% Concatenate data into a matrix
disp('Computing all pairwise distances...');
tic();
data_matrix = [features.data];
pdists = pdist(data_matrix.', dist);
pdists_mean = mean(pdists);
pdists_std = std(pdists);
pdists_length = length(pdists);
toc();

%%
disp('Computing distances within instruments...');
tic();
instrument_ids = [features.instrument_id];
nInstruments = max(instrument_ids);
mean_instrument_dist = zeros(nInstruments, 1);
std_instrument_dist = zeros(nInstruments, 1);
length_instrument_dist = zeros(nInstruments, 1);
for instrument_id = 1:nInstruments
    instrument_mask = (instrument_ids==instrument_id);
    instrument_features = features(instrument_mask);
    instrument_data = [instrument_features.data];
    instrument_pdists = pdist(instrument_data.', dist);
    mean_instrument_dist(instrument_id) = mean(instrument_pdists);
    std_instrument_dist(instrument_id) = std(instrument_pdists);
    length_instrument_dist(instrument_id) = length(instrument_pdists);
end
toc();
%%
nFiles = length(features);
batch_ids = [features.batch_id];
instrument_ids = [features.instrument_id];
nuance_ids = [features.nuance_id];
pitch_ids = [features.pitch_id];
style_ids = [features.style_id];

disp('Computing distances related to pitch, nuance, and style...');
tic();
for file_id = 1:nFiles
    batch_id = batch_ids(file_id);
    instrument_id = instrument_ids(file_id);
    nuance_id = nuance_ids(file_id);
    pitch_id = pitch_ids(file_id);
    style_id = style_ids(file_id);
    uppitch_id = find((batch_ids==batch_id) & ...
        (nuance_ids==nuance_id) & (pitch_ids==(pitch_id+1)));
    if ~isempty(uppitch_id)
        x = features(uppitch_id).data;
        y = features(file_id).data;
        features(file_id).pitch_dist = pdist(cat(1, x', y'), dist);
    end
    upnuance_id = find((batch_ids==batch_id) & ...
        (nuance_ids==(nuance_id+1)) & (pitch_ids==pitch_id));
    if ~isempty(upnuance_id)
        x = features(upnuance_id).data;
        y = features(file_id).data;
        features(file_id).nuance_dist = pdist(cat(1, x', y'), dist);
    end
    nextstyle_id = find((style_ids==(1+mod(style_id+1-1,3))) & ...
        (nuance_ids==nuance_id) & (pitch_ids==pitch_id) & ...
        (instrument_ids==instrument_id));
    if ~isempty(nextstyle_id)
        x = features(nextstyle_id).data;
        y = features(file_id).data;
        features(file_id).style_dist = pdist(cat(1, x', y'), dist);
    end
end
toc();
%%
pitch_dists = [features.pitch_dist];
mean_pitch_dist = mean(pitch_dists);
std_pitch_dist = std(pitch_dists);
length_pitch_dist = length(pitch_dists);

nuance_dists = [features.nuance_dist];
mean_nuance_dist = mean(nuance_dists);
std_nuance_dist = std(nuance_dists);
length_nuance_dist = length(nuance_dists);

style_dists = [features.style_dist];
mean_style_dist = mean(style_dists);
std_style_dist = std(style_dists);
length_style_dist = length(style_dists);

%%
mean_pitch_dist_per_instr = zeros(1, nInstruments);
std_pitch_dist_per_instr = zeros(1, nInstruments);
length_pitch_dist_per_instr = zeros(1, nInstruments);

mean_nuance_dist_per_instr = zeros(1, nInstruments);
std_nuance_dist_per_instr = zeros(1, nInstruments);
length_nuance_dist_per_instr = zeros(1,nInstruments);

mean_style_dist_per_instr = zeros(1, nInstruments);
std_style_dist_per_instr = zeros(1, nInstruments);
length_style_dist_per_instr = zeros(1, nInstruments);

for instrument_id = 1:nInstruments
    instrument_features = features([features.instrument_id] == instrument_id);

    instrument_pitch_dists = [instrument_features.pitch_dist];
    mean_pitch_dist_per_instr(instrument_id) = ...
        mean(instrument_pitch_dists);
    std_pitch_dist_per_instr(instrument_id) = ...
        std(instrument_pitch_dists);
    length_pitch_dist_per_instr(instrument_id) = ...
        length(instrument_pitch_dists);
    
    instrument_nuance_dists = [instrument_features.nuance_dist];
    mean_nuance_dist_per_instr(instrument_id) = ...
        mean(instrument_nuance_dists);
    std_nuance_dist_per_instr(instrument_id) = ...
        std(instrument_nuance_dists);
    length_nuance_dist_per_instr(instrument_id) = ...
        length(instrument_nuance_dists);
    
    instrument_style_dists = [instrument_features.style_dist];
    mean_style_dist_per_instr(instrument_id) = ...
        mean(instrument_style_dists);
    std_style_dist_per_instr(instrument_id) = ...
        std(instrument_style_dists);
    length_style_dist_per_instr(instrument_id) = ...
        length(instrument_style_dists);
end

%%
summary.dist = dist;
summary.absdist_mean = pdists_mean;
summary.absdist_std = pdists_std;
summary.absdist_length = pdists_length;
summary.pitch_reldist_mean = mean_pitch_dist / pdists_mean;
summary.pitch_reldist_std = std_pitch_dist / pdists_mean;
summary.pitch_reldist_length = length_pitch_dist;
summary.nuance_reldist_mean = mean_nuance_dist / pdists_mean;
summary.nuance_reldist_std = std_nuance_dist / pdists_mean;
summary.nuance_reldist_length = length_nuance_dist;
summary.style_reldist_mean = mean_style_dist / pdists_mean;
summary.style_reldist_std = std_style_dist / pdists_mean;
summary.style_reldist_length = length_style_dist;
summary.withininstrument_reldist_means = mean_instrument_dist / pdists_mean;
summary.withininstrument_reldist_stds = std_instrument_dist / pdists_mean;
summary.withininstrument_reldist_lengths = length_instrument_dist;
summary.withininstrument_reldist_globalmean = ...
    mean(summary.withininstrument_reldist_means);
summary.withininstrument_reldist_globalstd ...
    mean(summary.withininstrument_reldist_stds);
summary.setting = setting;

%% Save summary
prefix = setting2prefix(setting);
if ~exist(prefix, 'dir')
    mkdir(prefix);
end
filename = [prefix, '_summary'];
filepath = [prefix, '/', filename];
save(filepath, 'summary');
