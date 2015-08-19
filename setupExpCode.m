% Pull latest master of scattering.m
cd('~/scattering.m');
system('git pull origin master');
cd('~/rwc-scattering');

% Pull latest master of rwcInstrument project
system('git pull origin master');

% Move .expCode hidden folder to home
system('rsync -a .expCode ~/');

% Add expCode to path
addpath(genpath('~/expCode'));
addpath(genpath('~/scattering.m'));

% Create experiment
expCreate('rwcInstruments');
rwcInstruments('addStep','scattering');
rwcInstruments('addFactor',{'arch',{'plain'}});
rwcInstruments('addFactor', {'batch_id','1:45'})
rwcInstruments('addFactor',{'Q',{'8','16'}});
rwcInstruments('addFactor',{'mu',{'1e-2','1','1e2'}});
