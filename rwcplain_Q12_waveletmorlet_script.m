setting.arch = 'plain';
setting.Q = 12;
setting.wavelet = 'morlet';

nBatches = 45;
for batch_id = 1:nBatches
    compute_batch(batch_id, setting);
end