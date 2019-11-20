clc; close all; clear all;
load("hmm.mat");

% addpath(genpath('\HMMall')) 

%rng(sum('MarkRobinson'), 'default');

% learn parameters
[q1, prior1, transmat1, obsmat1, llVal1, LL1, loglik1] = estParams(data1, 3);
[q2, prior2, transmat2, obsmat2, llVal2, LL2, loglik2] = estParams(data2, 3);

% classify sequences
X = [X1 ; X2 ; X3 ; X4 ; X5 ; X6];
class = classify(X, prior1, prior2, transmat1, transmat2, obsmat1, obsmat2);


clc;
% show the results
displayResults(1, LL1, llVal1, q1, prior1, obsmat1, transmat1, loglik1);
displayResults(2, LL2, llVal2, q2, prior2, obsmat2, transmat2, loglik2);

function displayResults(j, ll, llVal, q, prior, obsmat, transmat, loglik)  
figure(j)
plot(1:1:length(loglik), loglik);
title('Logarithmic Likelihood of sequence')
ylabel('Log Likelihood')
xlabel('Number of states')
fprintf('---------------------------------\n');
fprintf('|          Process: %d            |\n', j);
fprintf('---------------------------------\n');
fprintf('States: %d\nObservations: %d\n',q,3);
fprintf('Initial Priors:\n');
prior
fprintf('Observation Probabilies:\n');
obsmat
fprintf('Transition Probablities:\n');
transmat
fprintf('Logarithmic Likelihood: %f\n', llVal);
fprintf('---------------------------------\n');
end



function [stateCount, prior, transmat, obsmat, llVal, LL, loglik] = estParams(data, obCount)
prior = {};
transmat = {};
obsmat = {};
loglik = [];
LL = {};

rng(sum('MarkRobinson'), 'twister');
for q=1:1:20
    prior{q} = normalise(rand(q,1));
    transmat{q} = mk_stochastic(rand(q,q));
    obsmat{q} = mk_stochastic(rand(q,obCount));
    [LL{q}, prior{q}, transmat{q}, obsmat{q}] = dhmm_em(data, prior{q}, transmat{q}, obsmat{q}, 'max_iter', 5);
    loglik(q) = dhmm_logprob(data, prior{q}, transmat{q}, obsmat{q});
end
[llVal, I] = max(loglik);
prior = prior{I};
transmat = transmat{I};
obsmat = obsmat{I};
stateCount = I;
LL = LL{q};
end

function [class] = classify(X, prior1, prior2, transmat1, transmat2, obsmat1, obsmat2)
class = zeros(1,6);
for i=1:1:6
    x = X(i,:);
    loglik1 = dhmm_logprob(x, prior1, transmat1, obsmat1);
    loglik2 = dhmm_logprob(x, prior2, transmat2, obsmat2);
    if loglik1 >= loglik2
        class(i) = 1;
    else
        class(i) = 2;
    end
end
end
