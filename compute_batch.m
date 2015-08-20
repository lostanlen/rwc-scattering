function batch = compute_batch(batch_id, setting)
% Build scattering filter banks
opts{1}.time.T = 16384; % 370 ms @ 44,1 kHz
opts{1}.time.max_Q = setting.Q;
opts{1}.time.max_scale = 4410.0; % 100 ms @ 44,1 kHz
opts{1}.time.gamma_bounds = [1 10*setting.Q]; % 10 octaves from 21 Hz to 22,050 kHz

opts{1}.nonlinearity.name = 'uniform_log';
opts{1}.nonlinearity.denominator = setting.mu;

opts{2}.time.handle = @gammatone_1d;
opts{2}.time.sibling_mask_factor = 2.0;
opts{2}.time.U_log2_oversampling = 2;

if ~strcmp(setting.arch, 'plain')
    error('non-plain scattering not ready yet');
end

opts{2}.nonlinearity.name = 'modulus';

archs = sc_setup(opts);

% Parse RWC folder
file_metas = parse_rwc('~/datasets/rwc');

% Filter folder according to specified batch
batch = file_metas([file_metas.batch_id] == batch_id);
nFiles = length(batch);

% Measure elapsed time with tic() and toc()
tic();
parfor file_index = 1:nFiles
    % Loading
    file_meta = file_metas(file_index);
    subfolder = file_meta.subfolder;
    wavfile_name = file_meta.wavfile_name;
    file_path = [dataPath, '/', subfolder, '/', wavfile_name];
    signal = audioread_compat(file_path);
    
    % Scattering
    S = sc_propagate(signal, archs);
    
    % Formatting
    batch(file_index).data = sc_format(S);
end
elapsed = toc();

% Get host name
pcinfo = java.net.InetAddress.getLocalHost();
host = pcinfo.getHostName();

% Get date
date = datestr(now());

Q_str = num2str(setting.Q,'%0.2d');
mu_str = num2str(setting.mu,'%1.0e');
batch_id_str = num2str(batch_id,'%0.2');
savefile_name = ['rwcplain_Q', Q_str, '_mu', mu_str, '_batch', batch_id_str];
savefile_path = ['storage/', savefile_name];

save(savefile_path, 'batch', 'setting', 'elapsed', 'date');
end


