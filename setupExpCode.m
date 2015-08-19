addpath(genpath('~/expCode'));
addpath(genpath('~/scattering.m'))

%%
expCreate('rwcInstruments');
rwcInstruments('addStep','scattering');
rwcInstruments('addFactor',{'arch',{'plain'}});
rwcInstruments('addFactor',{'Q',{'8','16'}});
rwcInstruments('addFactor',{'mu',{'1e-2','1','1e2'}})

rwcScattering('addStep','pca');
rwcScattering('addFactor',{'rank',{'50','100'}, '2'})
