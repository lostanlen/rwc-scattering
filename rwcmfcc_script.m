setting.arch = 'mfcc';

nBatches = 45;
for batch_id = 1:nBatches
    batch = compute_batch(batch_id, setting);
end
