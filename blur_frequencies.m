function S = blur_frequencies(S, F)
%% Set options
S = rwcbatch(1).S;
opt.T = 8;
opt.size = 2^nextpow2(size(S{1+1}.data,2));
opt.has_multiple_support = true;
opt.key.time{1}.gamma{1} = [];
opt.subscripts = 2;
invariant.spec = fill_invariant_spec(opt);
invariant.behavior = fill_invariant_behavior(opt);

% Setup bank
invariant = setup_invariant(invariant);

% First layer
% Pad
padding = zeros(size(S{1+1}.data, 1), opt.size - size(S{1+1}.data, 2));
unpadded_proportion = size(S{1+1}.data, 2) / opt.size;
S{1+1}.data = cat(2, S{1+1}.data, padding);

% Blur
S{1+1} = perform_ft(S{1+1}, invariant.behavior.key);
S{1+1} = blur_Y(S{1+1}, invariant);

% Unpad
nUnpadded_frequencies = round(unpadded_proportion * size(S{1+1}.data, 2));
S{1+1}.data = S{1+1}.data(:, 1:nUnpadded_frequencies);

%% Second layer
% Loop across lambda_2
nLambda2s = length(S{1+2}.data);
for lambda2_index = 1:nLambda2s
    %%
    lambda2_index = 1
    sub_S2 = S{1+2}.data{lambda2_index};
    % Pad
    padded_size = 2^nextpow2(size(sub_S2, 2));
    padding = zeros(size(sub_S2, 1), padded_size - size(sub_S2, 2));
    sub_S2 = cat(2, sub_S2, padding);
    % Blur
end
end