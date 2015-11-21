function batch = compute_batch(batch_id, setting)
if ~strcmp(setting.arch, 'mfcc')
    archs = setup_scattering(setting);
end

% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');

% Filter folder according to specified batch
rwcbatch = file_metas([file_metas.batch_id] == batch_id);
nFiles = length(rwcbatch);

% Measure elapsed time with tic() and toc()
tic();
if strcmp(setting.arch, 'mfcc')
    parfor file_index = 1:nFiles
        % Loading
        file_meta = file_metas(file_index);
        subfolder = file_meta.subfolder;
        wavfile_name = file_meta.wavfile_name;
        file_path = ['~/datasets/rwc/', subfolder, '/', wavfile_name];
        [signal, sample_rate] = audioread_compat(file_path);
        mfcc = melfcc(signal, sample_rate);
        % We remove the first line, which corresponds to energy coefficient
        data = mfcc(2:end, :);
        rwcbatch(file_index).signal = signal;
        rwcbatch(file_index).data = data;
        rwcbatch(file_index).setting = setting;
    end
else
    parfor file_index = 1:nFiles
        %%
        file_index
        file_meta = file_metas(file_index);
        subfolder = file_meta.subfolder;
        wavfile_name = file_meta.wavfile_name;
        file_path = ['~/datasets/rwc/', subfolder, '/', wavfile_name];
        signal = audioread_compat(file_path);
        signal = signal(1:65536);
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
        rwcbatch(file_index).setting = setting;
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
savefile_name = [setting2prefix(setting), '_batch', batch_id_str];
if ~exist('features','dir')
    mkdir('features');
end
savefile_path = ['features/', savefile_name];
save(savefile_path, 'rwcbatch', 'setting', 'host', 'elapsed', 'date');

% Print termination message
disp('--------------------------------------------------------------------------------');
disp(['Finished batch ', batch_id_str, ' on host ', host, ...
    ' at ', date,' with settings:']);
disp(setting);
disp(['Elapsed time is ', elapsed_str ' seconds.']);
end
