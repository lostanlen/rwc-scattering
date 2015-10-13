function summarized_batch = summarize_batch(batch, summarization_str)
nFiles = length(batch);
summarized_batch = batch;
switch summarization_str
    case 'none'
    case 'mean'
        for file_id = 1:nFiles
            summarized_batch(file_id).data = mean(batch(file_id).data);
        end
end
end

