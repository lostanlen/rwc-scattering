% Pull latest master of scattering.m
cd('~/scattering.m');
system('git pull origin master');
cd('~/rwc-scattering');

% Pull latest master of rwcInstrument project
system('git pull origin master');

% Move .expCode hidden folder to home
system('rsync -a .expCode ~/');

% Add expCode to path
addpath(genpath('expCode'));

% Add scattering.m to path
addpath(genpath('~/scattering.m'));

% Delete previous experiment
system('rm -rf rwcInstruments');

% Create experiment
expCreate('rwcInstruments');
rwcInstruments('addStep','scattering');
rwcInstruments('addFactor',{'arch',{'plain'}});
rwcInstruments('addFactor',{'mu',{'1e-2','1','1e2'}});
rwcInstruments('addFactor',{'Q',{'8','16'}});
rwcInstruments('addFactor', {'batch_id','1:45'});

% Move code to experiment folder
system('rsync -a rwin1scattering.m ./rwcInstruments/')
