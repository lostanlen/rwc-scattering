function batch = compute_batch(batch_id, setting)
if ~strcmp(setting.arch, 'mfcc')
    % Build scattering filter banks
    % First order
    % 370 ms @ 44,1 kHz
    opts{1}.time.T = 16384;
    opts{1}.time.max_Q = setting.Q;
    % 100 ms @ 44,1 kHz
    opts{1}.time.max_scale = 4410.0;
    % 10 octaves from 21 Hz to 22,050 kHz
    opts{1}.time.gamma_bounds = [1 10*setting.Q];
    % Gammatone wavelet
    opts{1}.time.handle = @gammatone_1d;
    % First nonlinearity
    if isfield(setting, 'mu')
        opts{1}.nonlinearity.name = 'uniform_log';
        opts{1}.nonlinearity.denominator = setting.mu;
    else
        opts{1}.nonlinarity.name = 'modulus';
    end
    % Second order
    opts{2}.time.handle = @gammatone_1d;
    opts{2}.time.sibling_mask_factor = 2.0;
    opts{2}.time.U_log2_oversampling = 2;
    % Joint scattering
    if strcmp(setting.arch, 'joint')
        opts{2}.gamma = struct();
    end
    % Spiral scattering
    if strcmp(setting.arch, 'spiral')
        opts{2}.gamma.handle = @morlet_1d;
        opts{2}.j.handle= @finitediff_1d;
    end
    % Second nonlinearity
    opts{2}.nonlinearity.name = 'modulus';
    archs = sc_setup(opts);
    % Frequency transposition invariance
    opts{3}.invariants.time.invariance = 'maxpooled';
    opts{3}.invariants.gamma.invariance = 'summed';
    % Setup architectures
    archs = sc_setup(opts);
end

% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');

% Filter folder according to specified batch
batch = file_metas([file_metas.batch_id] == batch_id);
nFiles = length(batch);

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
        rwcbatch(file_index).data = mfcc(2:end,:);
        rwcbatch(file_index).setting = setting;
    end
else
    parfor file_index = 1:nFiles
        file_meta = file_metas(file_index);
        subfolder = file_meta.subfolder;
        wavfile_name = file_meta.wavfile_name;
        file_path = ['~/datasets/rwc/', subfolder, '/', wavfile_name];
        signal = audioread_compat(file_path);
        S = sc_propagate(signal, archs);
        % Formatting
        layers = 2:3;
        formatted_layers = cell(length(layers),1);
        for layer_index = layers
            formatted_layers{layer_index} = ...
            format_layer(S{layer_index}, spatial_subscripts);
        end
        rwcbatch(file_index).data = [formatted_layers{:}].';
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
