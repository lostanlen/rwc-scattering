function config = rwinReport(config)                           
% rwinReport REPORTING of the expCode experiment rwcInstruments
%    config = rwinInitReport(config)                           
%       config : expCode configuration state                   
                                                               
% Copyright: Vincent Lostanlen                                 
% Date: 18-Aug-2015                                            
                                                               
if nargin==0, rwcInstruments('report', 'r'); return; end       
                                                               
config = expExpose(config, 't');                               
