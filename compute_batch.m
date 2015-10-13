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
    switch setting.wavelet
        case 'morlet'
            opts{1}.time.handle = @morlet_1d;
        case 'gammatone'
            opts{1}.time.handle = @gammatone_1d;
    end
    % First nonlinearity
    if isfield(setting, 'mu')
        opts{1}.nonlinearity.name = 'uniform_log';
        opts{1}.nonlinearity.denominator = setting.mu;
    else
        opts{1}.nonlinarity.name = 'modulus';
    end
    % Second order
    opts{2}.time.handle = opts{1}.time.handle;
    opts{2}.time.sibling_mask_factor = 2.0;
    opts{2}.time.U_log2_oversampling = 2;
    % Joint scattering
    if strcmp(setting.arch, 'joint')
        opts{2}.gamma.handle = @morlet_1d;
    end
    % Second nonlinearity
    opts{2}.nonlinearity.name = 'modulus';
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
        batch(file_index).data = melfcc(signal, sample_rate);
        batch(file_index).setting = setting;
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
        batch(file_index).data = sc_format(S);
        batch(file_index).setting = setting;
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
save(savefile_path, 'batch', 'setting', 'host', 'elapsed', 'date');

% Print termination message
disp('--------------------------------------------------------------------------------');
disp(['Finished batch ', batch_id_str, ' on host ', host, ...
    ' at ', date,' with settings:']);
disp(setting);
disp(['Elapsed time is ', elapsed_str ' seconds.']);
end
