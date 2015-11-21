setting.arch = 'joint';
setting.Q = 12;

nBatches = 2;
for batch_id = 1:nBatches
    compute_batch(batch_id, setting);
end
