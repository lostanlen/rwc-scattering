function [config, store, obs] = rwin1scattering(config, setting, ~)               
% rwin1scattering SCATTERING step of the expCode experiment rwcInstruments           
%    [config, store, obs] = rwin1scattering(config, setting, data)                   
%      - config : expCode configuration state                                        
%      - setting   : set of factors to be evaluated                                  
%      - data   : processing data stored during the previous step                    
%      -- store  : processing data to be saved for the other steps                   
%      -- obs    : observations to be saved for analysis                             
                                                                                     
% Copyright: Vincent Lostanlen                                                       
% Date: 18-Aug-2015                                                                  
                                                                                     
% Set behavior for debug mode                                                        
if nargin==0, rwcInstruments('do', 1, 'mask', {}); return; else store=[]; obs=[]; end

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
dataPath = setting.dataPath;
file_metas = parse_rwc(dataPath);

% Filter folder according to specified batch
file_metas = file_metas([file_metas.batch_id] == setting.batch_id);
nFiles = length(file_metas);
store = file_metas;

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
store(file_index).data = sc_format(S);
end


obs = [];


