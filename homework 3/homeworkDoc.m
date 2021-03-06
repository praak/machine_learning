%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Homework assignment 3
% Team:
% James Buckey, Kendrick Li & Praakrit Pradhan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This implements a simplified version of the SMO algorithm.  Currently we
% are not able to get the full algorithm to work because of a general lack
% of resources available
%
% The simplified SMO algorithm randomly selects alpha1 and alpha2 to
% optimize, so this will not diverge completely.  We just run the algorithm
% a set number of times to get something close to an identifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clean workspace
clear all; clc;

heart = dlmread('heart.txt');   % Import text file
median = heart(1,:);            % Get the median : the first row of data
heart(1,:) = [];                % Remove the first row of data
hLength = length(heart);        % Calculate length of the data
colNum = length(heart(1,:));    % Calculate num of columns

C = 1000;                      % define C, see http://stats.stackexchange.com/a/159051
tol = 1.0e-12;                  % define tolerance, we don't know where this comes from but should be small

% Set the number of tests from the training set
teLength = 50;                  % testing length
if teLength > hLength
    teLength = 2;               % we need some training data
end
trLength = hLength - teLength;  % training length

% generate training and testing cell arrays of datapoints and binary classifiers
S = cell(trLength, 2);
Stest = cell(teLength, 2);
for n = 1:hLength
    if n <= trLength
        S(n, 1) = {heart(n, :)};
        S(n, 2) = {binaryClassifier(heart(n, :), median)};
    else
        Stest(n - trLength, 1) = {heart(n, :)};
        Stest(n - trLength, 2) = {binaryClassifier(heart(n, :), median)};
    end
end

% START LEARNING
%------------------------------------------------------

% gen initial values
alpha = ones(trLength, 1);
b = 0;

% run loop x amount of times, the more times the more detailed alpha becomes
num = 1000;
while num > 0
    num = num - 1;
    
    % calculate EV for each datapoint
    SVMOutput = zeros(trLength, 1);
    for i = 1:trLength
        SVMOutput(i) = sum((cell2mat(S(:,1))*S{i,1}').*cell2mat(S(:,2)).*alpha) + b;
    end
    EV = SVMOutput - cell2mat(S(:,2));
    
    % calculate weight vector
    weightV = ((alpha.*cell2mat(S(:,2)))'*cell2mat(S(:,1)))';
    
    % calculate KKT
    KKTV = ((cell2mat(S(:,1))*weightV + b).*cell2mat(S(:,2)) - 1).*alpha;
    
    % pick x1 based off vectors
    [~, i1] = max(KKTV);
    x1 = S{i1, 1};
    eV = EV(i1) - EV;
    
    % pick x2 based off vectors
    [~, i2] = max(abs(eV));
    x2 = S{i2, 1};
    
    % Just pick random numbers not equal to each other because it always
    % pics the same indexes otherwise
    i1 = ceil(rand*trLength);
    i2 = ceil(rand*trLength);
    while i2 == i1
        i2 = ceil(rand*trLength);
    end
    
    % since we repicked our i1 and i2, recalculate eV
    eV = EV(i1) - EV;
    
    % calculate k
    k = kernel(x1, x1) + kernel(x2, x2) - 2*kernel(x1, x2);
    
    % if k is zero we can't do anything
    if k ~= 0 
        oldAlpha1 = alpha(i1);
        oldAlpha2 = alpha(i2);
        
        % calculate L and H
        if S{i1,2} ~= S{i2,2}
            L = max(0, alpha(i2) - alpha(i1));
            H = min(C, C + alpha(i2) - alpha(i1));
        else
            L = max(0, alpha(i1) + alpha(i2) - C);
            H = min(C, alpha(i1) + alpha(i2));
        end
        
        % update alpha 2
        alpha(i2) = oldAlpha2 - (S{i2, 2}*eV(i2))/k;
        
        if alpha(i2) > H
            alpha(i2) = H;
        elseif alpha(i2) < L
            alpha(i2) = L;
        end

        % update alpha 1
        alpha(i1) = alpha(i1) + S{i1, 2}*S{i2, 2}*(oldAlpha2 - alpha(i2));

        % simplify 
        alpha(alpha < tol) = 0;
    end
    
    % calculate new b
    b1 = b - EV(i1) - S{i1,2}*(alpha(i1) - oldAlpha1)*kernel(x1, x1) - S{i2,2}*(alpha(i2) - oldAlpha2)*kernel(x1, x2);
    b2 = b - EV(i2) - S{i1,2}*(alpha(i1) - oldAlpha1)*kernel(x1, x2) - S{i2,2}*(alpha(i2) - oldAlpha2)*kernel(x2, x2);
    
    if alpha(i1) > 0 && alpha(i1) < C
        b = b1;
    elseif alpha(i2) > 0 && alpha(i2) < C
        b = b2;
    else
        b = (b1 + b2)/2;
    end
    
    % test classification
    [prediction SVMValues] = classify(S, S, alpha, b);
    
    % test the accuracy of our alpha and bias values
    correct = prediction == cell2mat(S(:, 2));
    percentCorrect = sum(correct)/trLength * 100;
end

% Actually do test
[testPred testSVMValues] = classify(S, Stest, alpha, b);
testCorrect = testPred == cell2mat(Stest(:, 2));
testPerCorrect = sum(testCorrect)/teLength * 100; % how accurate our alpha and bias are

%{
references:
http://cs229.stanford.edu/materials/smo.pdf <------ This implementation is
based off this resource

SVM_KernelsOctober11-2016.pdf
SVM_Notes10-03-16.pdf
https://en.wikipedia.org/wiki/Sequential_minimal_optimization
%}
