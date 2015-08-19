% Move .expCode hidden folder
movefile('.expCode', '~/')

% Add expCode to path
addpath(genpath('~/expCode'));
addpath(genpath('~/scattering.m'))

% Create experiment
expCreate('rwcInstruments');
rwcInstruments('addStep','scattering');
rwcInstruments('addFactor',{'arch',{'plain'}});
rwcInstruments('addFactor',{'Q',{'8','16'}});
rwcInstruments('addFactor',{'mu',{'1e-2','1','1e2'}})

rwcInstruments('addStep','pca');
rwcInstruments('addFactor',{'rank',{'50','100'}, '2'})
