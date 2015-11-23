function rwcbatch = compute_batch(batch_id, setting)
if ~strcmp(setting.arch, 'mfcc')
    archs = setup_scattering(setting);
    N = 131072;
end

% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');

% Filter folder according to specified batch
rwcbatch = file_metas([file_metas.batch_id] == batch_id);


% Narrow the pitch range to 31 pitches
pitches = unique([rwcbatch.pitch_id]);
pitch_median = median(pitches);
pitch_min = (pitch_median-15);
pitch_max = (pitch_median+15);
rwcbatch = rwcbatch([rwcbatch.pitch_id] >= pitch_min);
rwcbatch = rwcbatch([rwcbatch.pitch_id] <= pitch_max);

% Initialize fields signal, data, and setting
[rwcbatch.signal] = deal(0);
[rwcbatch.data] = deal(0);
[rwcbatch.setting] = deal(setting);

nFiles = length(rwcbatch);

% Measure elapsed time with tic() and toc()
tic();
if strcmp(setting.arch, 'mfcc')
    parfor file_index = 1:nFiles
        % Loading
        file_meta = rwcbatch(file_index);
        subfolder = file_meta.subfolder;
        wavfile_name = file_meta.wavfile_name;
        file_path = ['~/datasets/rwc/', subfolder, '/', wavfile_name];
        [signal, sample_rate] = audioread_compat(file_path);
        mfcc = melfcc(signal, sample_rate , ...
            'wintime', 0.016, ...
            'lifterexp', 0, ...
            'minfreq', 133.33, ...
            'maxfreq', 6855.6, ...
            'sumpower', 0);
        % We remove the first line, which corresponds to energy coefficient
        data = mfcc(2:end, :);
        rwcbatch(file_index).signal = signal;
        rwcbatch(file_index).data = data;
    end
else
    parfor file_index = 1:nFiles
        %%
        file_meta = rwcbatch(file_index);
        subfolder = file_meta.subfolder;
        wavfile_name = file_meta.wavfile_name;
        file_path = ['~/datasets/rwc/', subfolder, '/', wavfile_name];
        signal = audioread_compat(file_path);
        if length(signal)<N
            signal = cat(1, signal, zeros(N - length(signal), 1));
        else
            signal = signal(1:N);
        end
        S = sc_propagate(signal, archs);
        % Formatting
        layers = 2:3;
        formatted_layers = cell(length(layers),1);
        for layer_index = layers
            formatted_layers{layer_index} = format_layer(S{layer_index}, 1);
        end
        data = [formatted_layers{:}].';
        rwcbatch(file_index).signal = signal;
        rwcbatch(file_index).data = data;
    end
end
elapsed = toc();
elapsed_str = num2str(elapsed, '%2.0f');

% Get host name
pcinfo = java.net.InetAddress.getLocalHost();
host = pcinfo.getHostName(); % class is java.lang.String
host = char(host); % convert to MATLAB char array

% Get date
date = datestr(now());

% Save
batch_id_str = num2str(batch_id, '%1.2d');
prefix = setting2prefix(setting);
savefile_name = ['batch', batch_id_str];
if ~exist(prefix,'dir')
    mkdir(prefix);
end
savefile_path = [prefix, '/', savefile_name];
save(savefile_path, 'rwcbatch', 'setting', 'host', 'elapsed', 'date');

% Print termination message
disp('--------------------------------------------------------------------------------');
disp(['Finished batch ', batch_id_str, ' on host ', host, ...
    ' at ', date,' with settings:']);
disp(setting);
disp(['Elapsed time is ', elapsed_str ' seconds.']);
end
