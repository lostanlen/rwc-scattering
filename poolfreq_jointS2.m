function S = poolfreq_jointS2(S, B)
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
            % Read node
            node = blob{node_index};
            % Pad
            nFrequencies_in = size(node, 2);
            nFrequencies_out = ceil(nFrequencies_in / B);
            padding_length = nFrequencies_out * B - nFrequencies_in;
            padding = zeros(size(node, 1), padding_length, size(node, 3));
            node = cat(2, node, padding);
            % Reshape
            node = ...
                reshape(node, size(node, 1), B, nFrequencies_out, size(node, 3));
            % Max-pool
            node = max(node, [], 2);
            % Write node
            blob{node_index} = squeeze(node);
            % Update ranges
            sublayer.ranges{1+0}{blob_index}{node_index}(2,2) = B;
        end
        % Write blob
        sublayer.data{blob_index} = blob;
    end
    % Write sublayer
    S{1+2}{sublayer_index} = sublayer;
end
end