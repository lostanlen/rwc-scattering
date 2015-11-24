function S = blurfreq_jointS2(S, F)
%% Burn after reading
S = rwcbatch(1).S;
F = 2;
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

%% Second layer (manual)

nSublayers = length(S{1+2});
for sublayer_index = 1:nSublayers
    sublayer = S{1+2}{sublayer_index};
    if isempty(sublayer)
        continue
    end
    nBlobs = length(sublayer.data);
    for lambda2 = 1:nBlobs
        blob = sublayer.data{lambda2};
        nNodes = length(blob);
        for node_index = 1:nNodes
            node = blob{node_index};
            gamma_range = sublayer.ranges{1+0}{blob_index}{node_index}(:,2);
            gamma_stride = gamma_range(2);
            gamma_length = gamma_range(3) - gamma_range(1);
            % Pad
            node = cat(2, node, zeros(size(node)));
            % Select support
            % The last -1 is due to zero-padding by a factor 2
            support_index = ...
                1 + log2(invariant.spec.size) - log2(gamma_length) - 1;
            phi = invariant.phi{support_index};
            
            node = fft(node, [], 2);
            node(:, 1:length(phi.ft_pos), :) = bsxfun(@times, ...
                node(:, 1:length(phi.ft_pos), :), phi.ft_pos);
            node(:, (end-length(phi.ft_pos)+2):end, :) = bsxfun(@times, ...
                node(:, (end-length(phi.ft_pos)+2):end, :), ...
                phi.ft_pos(:, end:-1:2));
            node = ifft(node, [], 2);
            % Unpad
            node = node(:, 1:(end/2), :);
        end
    end
end
%%
end