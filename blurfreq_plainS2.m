function S = blurfreq_plainS2(S, F)
%% Set options
opt.T = F;
opt.size = 8 * 2^nextpow2(size(S{1+1}.data,2));
opt.has_multiple_support = true;
opt.key.time{1}.gamma{1} = [];
opt.subscripts = 2;
invariant.spec = fill_invariant_spec(opt);
invariant.behavior = fill_invariant_behavior(opt);

%% Setup bank
invariant = setup_invariant(invariant);

%% First layer
% Pad
padding = zeros(size(S{1+1}.data, 1), opt.size - size(S{1+1}.data, 2));
unpadded_proportion = size(S{1+1}.data, 2) / opt.size;
S{1+1}.data = cat(2, S{1+1}.data, padding);

% Blur
S{1+1} = perform_ft(S{1+1}, invariant.behavior.key);
S{1+1} = blur_Y(S{1+1}, invariant);

% Unpad
nUnpadded_frequencies = ceil(unpadded_proportion * size(S{1+1}.data, 2));
S{1+1}.data = S{1+1}.data(:, 1:nUnpadded_frequencies);

%% Second layer
% Pad
nLambda2s = length(S{1+2}.data);
unpadded_proportions = zeros(nLambda2s, 1);
for lambda2_index = 1:nLambda2s
    sub_S2 = S{1+2}.data{lambda2_index};
    padded_size = 8 * 2^nextpow2(size(sub_S2, 2));
    padding = zeros(size(sub_S2, 1), padded_size - size(sub_S2, 2));
    unpadded_proportions(lambda2_index) = size(sub_S2, 2) / padded_size;
    S{1+2}.data{lambda2_index} = cat(2, sub_S2, padding);
end

% Blur
S{1+2} = perform_ft(S{1+2}, invariant.behavior.key);
S{1+2} = blur_Y(S{1+2}, invariant);

% Unpad
for lambda2_index = 1:nLambda2s
    sub_S2 = S{1+2}.data{lambda2_index};
    unpadded_proportion = unpadded_proportions(lambda2_index);
    nUnpadded_frequencies = ceil(unpadded_proportion * size(sub_S2, 2));
    S{1+2}.data{lambda2_index} = real(sub_S2(:, 1:nUnpadded_frequencies));
end
end