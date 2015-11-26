function S = poolfreq_plainS2(S, B)
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
S1 = max(S1, [], 3);

% Write
S{1+1}.data = squeeze(S1);

% Update ranges
S{1+1}.ranges{1+0}(2,2) = B;

%% Second layer
nNodes = length(S{1+2}.data);
for node_index = 1:nNodes
    % Read
    S2 = S{1+2}.data{node_index};
    % Pad
    nFrequencies_in = size(S2, 2);
    nFrequencies_out = ceil(nFrequencies_in / B);
    padding_length = nFrequencies_out * B - nFrequencies_in;
    padding = zeros(size(S2, 1), padding_length);
    S2 = cat(2, S2, padding);
    % Reshape
    S2 = reshape(S2, size(S2, 1), B, nFrequencies_out);  
    % Max-pool
    S2 = max(S2, [], 2);
    % Write
    S{1+2}.data{node_index} = squeeze(S2);
    % Update ranges
    S{1+2}.ranges{1+0}{node_index}(2,2) = B;
end
end