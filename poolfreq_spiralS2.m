function S = poolfreq_spiralS2(S, B)
%% First layer
% Read
S1 = S{1+1}.data;

% Pad
nFrequencies_in = size(S1, 2);
nFrequencies_out = ceil(nFrequencies_in / B);
padding_length = nFrequencies_out * B - nFrequencies_in;
padding = zeros(size(S1, 1), padding_length);
S1 = cat(2, S1, padding);

% Reshape
S1 = reshape(S1, size(S1, 1), B, nFrequencies_out);

% Max-pool
S1 = max(S1, [], 2);

% Write
S{1+1}.data = squeeze(S1);

% Update ranges
S{1+1}.ranges{1+0}(2,2) = B;

%% Second layer
nSublayers = length(S{1+2});
for sublayer_index = 1:nSublayers
    % Read sublayer
    sublayer = S{1+2}{sublayer_index};
    if isempty(sublayer)
        continue
    end
    nBlobs = length(sublayer.data);
    for blob_index = 1:nBlobs
        % Read blob
        blob = sublayer.data{blob_index};
        nNodes = length(blob);
        for node_index = 1:nNodes
            % Read stride
            stride = sublayer.ranges{1+0}{blob_index}{node_index}(2,2);
            if stride <= B
                continue
            end
            % Read node
            node = blob{node_index};
            % Unspiral
            sizes = [size(node), 1];
            sizes = [sizes(1), sizes(2)*sizes(3), sizes(4:end)];
            node = reshape(node, sizes);
            % Pad
            restride = B / stride;
            nFrequencies_in = size(node, 2);
            nFrequencies_out = ceil(nFrequencies_in / restride);
            padding_length = nFrequencies_out * restride - nFrequencies_in;
            sizes = [size(node), 1];
            padding_sizes = sizes;
            padding_sizes(2) = padding_length;
            padding = zeros(padding_sizes);
            node = cat(2, node, padding);
            % Reshape
            sizes = [sizes(1), restride, nFrequencies_out, size(3:end)];
            node = reshape(node, sizes);
            % Max-pool
            node = restride * max(node, [], 2);
            % Write node
            blob{node_index} = squeeze(node);
            % Update unspiraling in metadata
            zeroth_ranges = sublayer.ranges{1+0}{blob_index};
            gamma_range = zeroth_ranges(:, 2);
            octave_range = zeroth_ranges(:, 3);
            nOctaves = octave_range(3) - octave_range(1);
            nFilters_per_octave = gamma_range(3) - gamma_range(1);
            gamma_range(3) = nFilters_per_octave * nOctaves;
            % Update stride
            gamma_range(2) = B;
            zeroth_ranges(:, 2) = gamma_range;
            zeroth_ranges(:, 3) = [];
            sublayer.ranges{1+0}{blob_index}{node_index} = zeroth_ranges;
        end
        % Write blob
        sublayer.data{blob_index} = blob;
    end
    % Write sublayer
    S{1+2}{sublayer_index} = sublayer;
end
end