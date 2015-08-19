%DEMHMC2 Demonstrate Bayesian regression with Hybrid Monte Carlo sampling.
%
%	Description
%	The problem consists of one input variable X and one target variable
%	T with data generated by sampling X at equal intervals and then
%	generating target data by computing SIN(2*PI*X) and adding Gaussian
%	noise. The settingl is a 2-layer network with linear outputs, and the
%	hybrid Monte Carlo algorithm (without persistence) is used to sample
%	from the posterior distribution of the weights.  The graph shows the
%	underlying function, 100 samples from the function given by the
%	posterior distribution of the weights, and the average prediction
%	(weighted by the posterior probabilities).
%
%	See also
%	DEMHMC3, HMC, MLP, MLPERR, MLPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)


% Generate the matrix of inputs x and targets t.
ndata = 20;                     % Number of data points.
noise = 0.1;                    % Standard deviation of noise distribution.
nin = 1;                        % Number of inputs.
nout = 1;                       % Number of outputs.

seed = 42;                    % Seed for random weight initialization.
randn('state', seed);
rand('state', seed);

x = 0.25 + 0.1*randn(ndata, nin);
t = sin(2*pi*x) + noise*randn(size(x));

clc
disp('This demonstration illustrates the use of the hybrid Monte Carlo')
disp('algorithm to sample from the posterior weight distribution of a')
disp('multi-layer perceptron.')
disp(' ')
disp('A regression problem is used, with the one-dimensional data drawn')
disp('from a noisy sine function.  The x values are sampled from a normal')
disp('distribution with mean 0.25 and variance 0.01.')
disp(' ')
disp('First we initialise the network.')
disp(' ')
disp('Press any key to continue.')
pause

% Set up network parameters.
nhidden = 5;			% Number of hidden units.
alpha = 0.001;                  % Coefficient of weight-decay prior. 
beta = 100.0;			% Coefficient of data error.

% Create and initialize network settingl.
% Initialise weights reasonably close to 0
net = mlp(nin, nhidden, nout, 'linear', alpha, beta);
net = mlpinit(net, 10);

clc
disp('Next we take 100 samples from the posterior distribution.  The first')
disp('200 samples at the start of the chain are omitted.  As persistence')
disp('is not used, the momentum is randomised at each step.  100 iterations')
disp('are used at each step.  The new state is accepted if the threshold')
disp('value is greater than a random number between 0 and 1.')
disp(' ')
disp('Negative step numbers indicate samples discarded from the start of the')
disp('chain.')
disp(' ')
disp('Press any key to continue.')
pause
% Set up vector of options for hybrid Monte Carlo.
nsamples = 100;			% Number of retained samples.

options = foptions;             % Default options vector.
options(1) = 1;			% Switch on diagnostics.
options(7) = 100;		% Number of steps in trajectory.
options(14) = nsamples;		% Number of Monte Carlo samples returned. 
options(15) = 200;		% Number of samples omitted at start of chain.
options(18) = 0.002;		% Step size.

w = mlppak(net);
% Initialise HMC
hmc('state', 42);
[samples, energies] = hmc('neterr', w, options, 'netgrad', net, x, t);

clc
disp('The plot shows the underlying noise free function, the 100 samples')
disp('produced from the MLP, and their average as a Monte Carlo estimate')
disp('of the true posterior average.')
disp(' ')
disp('Press any key to continue.')
pause
nplot = 300;
plotvals = [0 : 1/(nplot - 1) : 1]';
pred = zeros(size(plotvals));
fh = figure;
for k = 1:nsamples
  w2 = samples(k,:);
  net2 = mlpunpak(net, w2);
  y = mlpfwd(net2, plotvals);
  % Average sample predictions as Monte Carlo estimate of true integral
  pred = pred + y;
  h4 = plot(plotvals, y, '-r', 'LineWidth', 1);
  if k == 1
    hold on
  end
end
pred = pred./nsamples;

% Plot data
h1 = plot(x, t, 'ob', 'LineWidth', 2, 'MarkerFaceColor', 'blue');
axis([0 1 -3 3])

% Plot function
[fx, fy] = fplot('sin(2*pi*x)', [0 1], '--g');
h2 = plot(fx, fy, '--g', 'LineWidth', 2);
set(gca, 'box', 'on');

% Plot averaged prediction
h3 = plot(plotvals, pred, '-c', 'LineWidth', 2);
hold off

lstrings = char('Data', 'Function', 'Prediction', 'Samples');
legend([h1 h2 h3 h4], lstrings, 3);

disp('Note how the predictions become much further from the true function')
disp('away from the region of high data density.')
disp(' ')
disp('Press any key to exit.')
pause
close(fh);
clear all;

