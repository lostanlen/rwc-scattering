function prefix = setting2prefix(setting)
switch setting.arch
    case 'plain'
        Q_str = num2str(setting.Q,'%1.2d');
        if isfield(setting, 'mu')
            mu_str = num2str(setting.mu,'%1.0e');
            prefix = ['rwcplain_Q', Q_str, '_mu', mu_str, '_batch'];
        else
            prefix = ['rwcplain_Q', Q_str, '_batch'];
        end
    otherwise
        error(['Unknown arch setting', setting.arch]);
end
end
