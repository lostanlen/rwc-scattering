setting.arch = 'plain';
setting.Q = 12;
setting.mu = 1e-2;

nBatches = 45;
for batch_id = 1:nBatches
    compute_batch(batch_id, setting);
end
