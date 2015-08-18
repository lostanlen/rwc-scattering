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
                                                                                     
% imported data                                                                      
data                                                                                 
