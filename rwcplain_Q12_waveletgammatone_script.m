setting.arch = 'plain';
setting.Q = 12;
setting.wavelet = 'gammatone';

nBatches = 45;
for batch_id = 1:nBatches
    batch = compute_batch(batch_id, setting);
end
