function blurfreq_batch(batch_id, file_metas, setting)
%% Generate prefix string
prefix = setting2prefix(setting);
nBatches = 32;

%% Load batch
disp(['loading batch #', num2str(batch_id, '%0.2d')])
batch_id_str = num2str(batch_id, '%1.2d');
file_name = ['batch', batch_id_str];
file_path = [prefix, '/', file_name];
load(file_path);

%% Call blurfreq
switch setting.arch
    case 'plain'
        rwcbatch.S = blurfreq_plainS2(rwcbatch.S, setting.F);
    case 'joint'
        rwcbatch.S = blurfreq_jointS2(rwcbatch.S, setting.F);
    case 'spiral'
        rwcbatch.S = blurfreq_spiralS2(rwcbatch.S, setting.F);
end

%% Generate output file path
end