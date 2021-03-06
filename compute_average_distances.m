function [summary,features] = compute_average_distances(setting, features, dist)
if nargin < 3
    dist = 'euclidean';
end

%% Concatenate data into a matrix
disp('Computing all pairwise distances...');
tic();
data_matrix = [features.data];
if strcmp(dist, 'euclidean')
    pdists = pdist(data_matrix.', dist).^2;
else
    pdists = pdist(data_matrix.', dist);
end
pdists_mean = mean(pdists);
pdists_median = median(pdists);
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
    if strcmp(dist, 'euclidean')
        instrument_pdists = pdist(instrument_data.', dist).^2;
    else
        instrument_pdists = pdist(instrument_data.', dist);
    end
    mean_instrument_dist(instrument_id) = mean(instrument_pdists);
    median_instrument_dist(instrument_id) = median(instrument_pdists);
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
nStyles = max(style_ids);

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
        if strcmp(dist, 'euclidean')
            d = pdist(cat(1, x', y'), dist).^2;
        else
            d = pdist(cat(1, x', y'), dist);
        end
        features(file_id).pitch_dist = d;
    end
    upnuance_id = find((batch_ids==batch_id) & ...
        (nuance_ids==(nuance_id+1)) & (pitch_ids==pitch_id));
    if ~isempty(upnuance_id)
        x = features(upnuance_id).data;
        y = features(file_id).data;
        if strcmp(dist, 'euclidean')
            d = pdist(cat(1, x', y'), dist).^2;
        else
            d = pdist(cat(1, x', y'), dist);
        end
        features(file_id).nuance_dist = d;
    end
    nextstyle_id = find((style_ids==(1+mod(style_id+1-1,nStyles))) & ...
        (nuance_ids==nuance_id) & (pitch_ids==pitch_id) & ...
        (instrument_ids==instrument_id));
    if ~isempty(nextstyle_id)
        x = features(nextstyle_id).data;
        y = features(file_id).data;
        if strcmp(dist, 'euclidean')
            d = pdist(cat(1, x', y'), dist).^2;
        else
            d = pdist(cat(1, x', y'), dist);
        end
        features(file_id).style_dist = d;
    end
end
toc();
%%
pitch_dists = [features.pitch_dist];
mean_pitch_dist = mean(pitch_dists);
median_pitch_dist = median(pitch_dists);
std_pitch_dist = std(pitch_dists);
length_pitch_dist = length(pitch_dists);

nuance_dists = [features.nuance_dist];
mean_nuance_dist = mean(nuance_dists);
median_nuance_dist = median(nuance_dists);
std_nuance_dist = std(nuance_dists);
length_nuance_dist = length(nuance_dists);

style_dists = [features.style_dist];
mean_style_dist = mean(style_dists);
median_style_dist = median(style_dists);
std_style_dist = std(style_dists);
length_style_dist = length(style_dists);

%%
mean_pitch_dist_per_instr = zeros(1, nInstruments);
median_pitch_dist_per_inst = zeros(1, nInstruments);
std_pitch_dist_per_instr = zeros(1, nInstruments);
length_pitch_dist_per_instr = zeros(1, nInstruments);

mean_pitch_dist_per_instr = zeros(1, nInstruments);
median_pitch_dist_per_inst = zeros(1, nInstruments);
std_nuance_dist_per_instr = zeros(1, nInstruments);
length_nuance_dist_per_instr = zeros(1,nInstruments);

mean_style_dist_per_instr = zeros(1, nInstruments);
median_style_dist_per_inst = zeros(1, nInstruments);
std_style_dist_per_instr = zeros(1, nInstruments);
length_style_dist_per_instr = zeros(1, nInstruments);

for instrument_id = 1:nInstruments
    instrument_features = features([features.instrument_id] == instrument_id);

    instrument_pitch_dists = [instrument_features.pitch_dist];
    mean_pitch_dist_per_instr(instrument_id) = ...
        mean(instrument_pitch_dists);
    median_pitch_dist_per_instr(instrument_id) = ...
        median(instrument_pitch_dists);
    std_pitch_dist_per_instr(instrument_id) = ...
        std(instrument_pitch_dists);
    length_pitch_dist_per_instr(instrument_id) = ...
        length(instrument_pitch_dists);
    
    instrument_nuance_dists = [instrument_features.nuance_dist];
    mean_nuance_dist_per_instr(instrument_id) = ...
        mean(instrument_nuance_dists);
    median_nuance_dist_per_instr(instrument_id) = ...
        median(instrument_nuance_dists);
    std_nuance_dist_per_instr(instrument_id) = ...
        std(instrument_nuance_dists);
    length_nuance_dist_per_instr(instrument_id) = ...
        length(instrument_nuance_dists);
    
    instrument_style_dists = [instrument_features.style_dist];
    mean_style_dist_per_instr(instrument_id) = ...
        mean(instrument_style_dists);
    median_style_dist_per_instr(instrument_id) = ...
        median(instrument_style_dists);
    std_style_dist_per_instr(instrument_id) = ...
        std(instrument_style_dists);
    length_style_dist_per_instr(instrument_id) = ...
        length(instrument_style_dists);
end

%%
summary.dist = dist;
summary.absdist_mean = pdists_mean;
summary.absdist_median = pdists_median;
summary.absdist_std = pdists_std;
summary.absdist_length = pdists_length;
summary.pitch_reldist_mean = mean_pitch_dist / pdists_mean;
summary.pitch_reldist_median = median_pitch_dist / pdists_mean;
summary.pitch_reldist_std = std_pitch_dist / pdists_mean;
summary.pitch_reldist_length = length_pitch_dist;
summary.nuance_reldist_mean = mean_nuance_dist / pdists_mean;
summary.nuance_reldist_median = median_nuance_dist / pdists_mean;
summary.nuance_reldist_std = std_nuance_dist / pdists_mean;
summary.nuance_reldist_length = length_nuance_dist;
summary.style_reldist_mean = mean_style_dist / pdists_mean;
summary.style_reldist_median = median_style_dist / pdists_mean;
summary.style_reldist_std = std_style_dist / pdists_mean;
summary.style_reldist_length = length_style_dist;
summary.withininstrument_reldist_means = mean_instrument_dist / pdists_mean;
summary.withininstrument_reldist_medians = median_instrument_dist / pdists_mean;
summary.withininstrument_reldist_stds = std_instrument_dist / pdists_mean;
summary.withininstrument_reldist_lengths = length_instrument_dist;
summary.withininstrument_reldist_globalmean = ...
    mean(summary.withininstrument_reldist_means);
summary.withininstrument_reldist_globalmedian = ...
    median(summary.withininstrument_reldist_medians);
summary.withininstrument_reldist_globalstd = ...
    mean(summary.withininstrument_reldist_stds);
summary.instrument_names = ...
    arrayfun(@(i) features([features.instrument_id] == i).instrument_name, ...
    1:16, 'UniformOutput', false).';
summary.setting = setting;

%% Save summary
prefix = setting2prefix(setting);
if ~exist(prefix, 'dir')
    mkdir(prefix);
end
filename = [prefix, '_summary', '_', dist];
filepath = [prefix, '/', filename];
save(filepath, 'summary');
