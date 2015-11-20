function dist_summary = compute_average_distances(features, dist)
if nargin < 2
    dist = 'cosine';
end

%% Concatenate data into a matrix
disp('Computing all pairwise distances...');
tic();
data_matrix = [features.data];
pdists = pdist(data_matrix.', dist);
mean_pdists = mean(pdists);
toc();

%%
disp('Computing distances within instruments...');
tic();
instrument_ids = [features.instrument_id];
nInstruments = max(instrument_ids);
mean_instrument_pdists = zeros(nInstruments, 1);
std_instrument_pdists = zeros(nInstruments, 1);
for instrument_id = 1:nInstruments
    instrument_mask = (instrument_ids==instrument_id);
    instrument_features = features(instrument_mask);
    instrument_data = [instrument_features.data];
    instrument_pdists = pdist(instrument_data.', dist);
    mean_instrument_pdists(instrument_id) = mean(instrument_pdists);
    std_instrument_pdists(instrument_id) = std(instrument_pdists);
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
    if (uppitch_id~=0)
        x = features(uppitch_id).data;
        y = features(file_id).data;
        features(file_id).pitch_dist = pdist(cat(1, x, y), dist);
    end
    upnuance_id = find((batch_ids==batch_id) & ...
        (nuance_ids==(nuance_id+1)) & (pitch_ids==pitch_id));
    if (upnuance_id~=0)
        x = features(upnuance_id).data;
        y = features(file_id).data;
        features(file_id).nuance_dist = pdist(cat(1, x, y), dist);
    end
    nextstyle_id = find((style_ids==(1+mod(style_id+1-1,3))) & ...
        (nuance_ids==nuance_id) & (pitch_ids==pitch_id) & ...
        (instrument_ids==instrument_id));
    if (nextstyle_id~=0)
        x = features(nextstyle_id).data;
        y = features(file_id).data;
        features(file_id).style_dist = pdist(cat(1, x, y), dist);
    end
end
toc();
%%
mean_pitch_dist = mean([features.pitch_dist]);
mean_nuance_dist = mean([features.nuance_dist]);

%%
for instrument_id = 1:nInstruments
    mean_pitch_dist_per_instr(instrument_id) = ...
        mean([features([features.instrument_id]==instrument_id).pitch_dist]);
end
