function [config, store, obs] = rwin1scattering(config, setting, data)               
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

opts{1}.time.T = 16384; % 370 ms @ 44,1 kHz
opts{1}.time.max_Q = Q;
opts{1}.time.max_scale = 4410.0; % 100 ms @ 44,1 kHz
opts{1}.time.gamma_bounds = [1 9*Q]; % 9 octaves from 43 Hz to 22,050 kHz

opts{1}.nonlinearity.type = 'uniform_log';
opts{1}.nonlinearity.denominator = mu;

opts{2}.time.handle = @gammatone_1d;
opts{2}.time.sibling_mask_factor = 2.0;
opts{2}.time.U_log2_oversampling = 2;

archs = sc_setup(opts);



