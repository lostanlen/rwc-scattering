addpath(genpath('~/MATLAB/miningsuite-master'));

%% Load features
setting.arch = 'mfcc';
setting.numcep = 40;
% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');
nBatches = length(unique([file_metas.batch_id]));
features = load_features(setting, 'max');
%%

%% Measure intra-class distances at fixed nuance and pitch
feature_range = 2:13;
instrument_ids = [features.instrument_id];
nInstruments = max(instrument_ids);
mean_instrument_dist = zeros(nInstruments, 1);
mean_style_dist = zeros(nInstruments, 1);
mean_pitch_dist = zeros(nInstruments, 1);
mean_nuance_dist = zeros(nInstruments, 1);
std_instrument_dist = zeros(nInstruments, 1);
std_style_dist = zeros(nInstruments, 1);
std_pitch_dist = zeros(nInstruments, 1);
std_nuance_dist = zeros(nInstruments, 1);

for instrument_id = 1:nInstruments
    instrument_mask = (instrument_ids==instrument_id);
    instrument_features = features(instrument_mask);
    % Instrument
    instrument_data = [instrument_features.data];
    instrument_data = instrument_data(feature_range, :);
    instrument_pdists = pdist(instrument_data.', 'euclidean').^2;
    mean_instrument_dist(instrument_id) = mean(instrument_pdists);
    std_instrument_dist(instrument_id) = median(instrument_pdists);
    % Style
    styles = unique([instrument_features.style_id]);
    nStyles = length(styles);
    style_distances = zeros(1, nStyles);
    for style_index = 1:nStyles
        style_id = styles(style_index);
        style_ids = [instrument_features.style_id];
        style_mask = (style_ids==style_id);
        style_features = instrument_features(style_mask);
        style_data = [style_features.data];
        style_data = style_data(feature_range, :);
        style_pdists = pdist(style_data.', 'euclidean').^2;
        style_distances(style_id) = mean(style_pdists);
    end
    % Pitch
    pitches = unique([instrument_features.pitch_id]);
    nPitches = length(pitches);
    pitch_distances = zeros(1, nPitches);
    for pitch_index = 1:nPitches
        pitch_id = pitches(pitch_index);
        pitch_ids = [instrument_features.pitch_id];
        pitch_mask = (pitch_ids==pitch_id);
        pitch_features = instrument_features(pitch_mask);
        pitch_data = [pitch_features.data];
        pitch_data = pitch_data(feature_range, :);
        pitch_pdists = pdist(pitch_data.', 'euclidean').^2;
        pitch_distances(pitch_id) = mean(pitch_pdists);
    end
    % Nuance
    nuances = unique([instrument_features.nuance_id]);
    nNuances = length(nuances);
    nuance_distances = zeros(1, nNuances);
    for nuance_id = 1:nNuances
        nuance_ids = [instrument_features.nuance_id];
        nuance_mask = (nuance_ids==nuance_id);
        nuance_features = instrument_features(nuance_mask);
        nuance_data = [nuance_features.data];
        nuance_data = nuance_data(feature_range, :);
        nuance_pdists = pdist(nuance_data.', 'euclidean').^2;
        nuance_distances(nuance_id) = mean(nuance_pdists);
    end
    mean_style_dist(instrument_id) = mean(style_distances);
    std_style_dist(instrument_id) = std(style_distances);
    mean_pitch_dist(instrument_id) = mean(pitch_distances);
    std_pitch_dist(instrument_id) = std(pitch_distances);
    mean_nuance_dist(instrument_id) = mean(nuance_distances);
    std_nuance_dist(instrument_id) = std(nuance_distances);
end

[sorted_instrument_dist, sorting_indices] = ...
    sort(mean_instrument_dist, 'ascend');

sorted_mean_pitch_dist = mean_pitch_dist(sorting_indices);
sorted_mean_style_dist = mean_style_dist(sorting_indices);
sorted_mean_nuance_dist = mean_nuance_dist(sorting_indices);
sorted_std_pitch_dist = std_pitch_dist(sorting_indices);
sorted_std_style_dist = std_style_dist(sorting_indices);
sorted_std_nuance_dist = std_nuance_dist(sorting_indices);

sorted_instruments = cell(1, nInstruments);
for instrument_id = 1:nInstruments
    booleans = ...
        find([features.instrument_id]==sorting_indices(instrument_id), 1);
    sorted_instruments{instrument_id} = ...
        features(booleans).instrument_name;
end

required_instruments = {'Clarinet', 'Flute', 'Trumpet', 'Violin', ...
    'Tenor Saxophone', 'Piano'};

required_booleans = false(nInstruments, 1);
for instrument_id = 1:nInstruments
    required_booleans(instrument_id) = ...
        ismember(sorted_instruments{instrument_id}, required_instruments);
end

% Plot bar graph
bar_matrix = cat(2, ...
    sorted_instrument_dist(required_booleans), ...
    sorted_mean_style_dist(required_booleans), ...
    sorted_mean_nuance_dist(required_booleans), ...
    sorted_mean_pitch_dist(required_booleans));

h = barh(bar_matrix);
legend(h, {'Same instrument', ...
    'Same interpret', ...
    'Same nuance', ...
    'Same pitch'});
set(gca,'yticklabel', required_instruments);

%%
plot([sorted_instrument_dist,...
    sorted_mean_pitch_dist, ...
    sorted_mean_style_dist, ...
    sorted_mean_nuance_dist]);
