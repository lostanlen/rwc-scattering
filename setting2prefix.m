function prefix = setting2prefix(setting)
prefix = ['rwc', setting.arch];
if ~strcmp(setting.arch, 'mfcc')
    prefix = [prefix, '_Q', num2str(setting.Q, '%1.2d')];
    prefix = [prefix, '_wavelet', setting.wavelet];
    if isfield(setting, 'mu')
        mu_str = num2str(setting.mu,'%1.0e');
        prefix = [prefix, '_mu', mu_str];
    end
end
end
