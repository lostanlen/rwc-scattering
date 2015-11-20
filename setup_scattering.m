function archs = setup_scattering(setting)
% Build scattering filter banks
% First order
% 370 ms @ 44,1 kHz
opts{1}.time.T = 16384;
opts{1}.time.max_Q = setting.Q;
% 8 octaves
opts{1}.time.gamma_bounds = [1 8*setting.Q];
% Gammatone wavelet
opts{1}.time.handle = @gammatone_1d;
% Avoid chunking
opts{1}.time.is_chunked = false;
% First nonlinearity
if isfield(setting, 'mu')
    opts{1}.nonlinearity.name = 'uniform_log';
    opts{1}.nonlinearity.denominator = setting.mu;
else
    opts{1}.nonlinarity.name = 'modulus';
end
% Second order
opts{2}.banks.time.handle = @gammatone_1d;
opts{2}.banks.time.sibling_mask_factor = 2.0;
opts{2}.banks.time.U_log2_oversampling = 2;
% Joint scattering
if strcmp(setting.arch, 'joint')
    opts{2}.banks.gamma = struct();
end
% Spiral scattering
if strcmp(setting.arch, 'spiral')
    opts{2}.banks.gamma.handle = @morlet_1d;
    opts{2}.banks.j.handle= @finitediff_1d;
end
% Max-pooling
opts{2}.invariants.time.invariance = 'maxpooled';
% Second nonlinearity
opts{2}.nonlinearity.name = 'modulus';
% Frequency transposition invariance
opts{3}.invariants.time.invariance = 'maxpooled';
opts{3}.invariants.gamma.invariance = 'summed';
% Setup architectures
archs = sc_setup(opts);
end