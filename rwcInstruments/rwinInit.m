function [config, store] = rwinInit(config)                        
% rwinInit INITIALIZATION of the expCode experiment rwcInstruments 
%    [config, store] = rwinInit(config)                            
%      - config : expCode configuration state                      
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: Vincent Lostanlen                                     
% Date: 18-Aug-2015                                                
                                                                   
if nargin==0, rwcInstruments(); return; else store=[];  end        
