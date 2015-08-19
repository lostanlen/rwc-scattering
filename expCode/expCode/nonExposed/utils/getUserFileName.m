function configFileName = getUserFileName(shortExperimentName, experimentName, experimentPath, expCodePath)

% shortExperimentName = names2shortNames(experimentName);
% shortExperimentName = shortExperimentName{1};

if ~exist('expCodePath', 'var'), expCodePath = []; end

userName = getUserName();

configFileName = [experimentPath '/config' filesep shortExperimentName 'Config' [upper(userName(1)) userName(2:end)] '.txt'];

if ~exist(configFileName, 'file')
    if isempty(expCodePath)
        files = dir([experimentPath '/config/*Config*.txt']);
        defaultFileName = [experimentPath '/config/' files(1).name];
    else
        defaultFileName = [expCodePath '/expCodeConfig.txt'];
    end
    fprintf('Copying default config file for user %s from %s .\n', userName, defaultFileName);
    userDefaultConfigFileName = expUserDefaultConfig(defaultFileName);
    
    if ~exist(userDefaultConfigFileName, 'file')
        error(['Unable to find ' userDefaultConfigFileName '\n']);
    end
    fid = fopen(userDefaultConfigFileName, 'rt');
   
    fidw = fopen(configFileName, 'w');
     if fidw < 0
        error(['Unable to create ' configFileName '\n']);
    end
    while ~feof(fid)
        text = fgetl(fid);
        if line ~= -1
            text = strrep(text, '<experimentPath>', experimentPath);
            text = strrep(text, '<userName>', userName);
            text = strrep(text, '<experimentName>', experimentName);
            fprintf(fidw, '%s\n', text);
        end
    end
    fclose(fid);
    fclose(fidw);
    try
        open(configFileName);
    catch
        fprintf(2, 'Unable to open config file.');
    end
    disp(['Please update the file ' configFileName ' to suit your needs.']);
end