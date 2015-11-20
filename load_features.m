function features = load_features(setting, summarization_str)
if nargin<2
    summarization_str = 'mean';
end
% Generate prefix string
prefix = setting2prefix(setting);
nBatches = 45;
batch_features = cell(nBatches,1);
% Load batches
for batch_id = 1:nBatches
    disp(['loading batch #', int2str(batch_id)])
    batch_id_str = num2str(batch_id, '%1.2d');
    file_name = [prefix, '_batch', batch_id_str];
    file_path = [prefix, '/', file_name];
    load(file_path);
    rwcbatch = summarize_batch(rwcbatch, summarization_str);
    batch_features{batch_id} = rwcbatch;
end
% Convert cell array to vector
features = [batch_features{:}];
end
