function blurfreq_batch(batch_id, setting, F)
%% Generate prefix string
prefix = setting2prefix(setting);

%% Dispatch blurfreq according to architecture
switch setting.arch
    case 'plain'
        blurfreq_handle = @blurfreq_plainS2;
    case 'joint'
        blurfreq_handle = @blurfreq_jointS2;
    case 'spiral'
        blurfreq_handle = @blurfreq_spiralS2;
end

%% Load batch
batch_id_str = num2str(batch_id, '%1.2d');
file_name = ['batch', batch_id_str];
file_path = [prefix, '/', file_name];
load(file_path);

%% Loop over files
nFiles = length(rwcbatch);
tic();
parfor file_index = 1:nFiles
    rwcbatch(file_index).S = blurfreq_handle(rwcbatch(file_index).S, F);
end

%% Measure elapsed time
elapsed = toc();
elapsed_str = num2str(elapsed, '%2.0f');

%% Get host name
pcinfo = java.net.InetAddress.getLocalHost();
host = pcinfo.getHostName(); % class is java.lang.String
host = char(host); % convert to MATLAB char array

%% Get date
date = datestr(now());

%% Generate output file path
newsetting = setting;
newsetting.F = F;
newprefix = setting2prefix(newsetting);

%% Save
batch_id_str = num2str(batch_id, '%1.2d');
savefile_name = ['batch', batch_id_str];
if ~exist(newprefix,'dir')
    mkdir(newprefix);
end
savefile_path = [newprefix, '/', savefile_name];
save(savefile_path, 'rwcbatch', 'setting', 'host', 'elapsed', 'date');

%% Print termination message
% Print termination message
disp('--------------------------------------------------------------------------------');
disp(['Finished batch ', batch_id_str, ' on host ', host, ...
    ' at ', date,' with settings:']);
disp(setting);
disp(['Elapsed time is ', elapsed_str ' seconds.']);
end