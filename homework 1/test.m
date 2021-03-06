%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Machine Learning %
% Assignment 1 %
% Team: Buckey James, Li Kendrick, Pradhan Praakrit %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%test function
%  k = number of bins
%  returns [sentosaList, verisicolorList, verginicaList, sentosaTest,
%  verisicolorTest, verginicaTest]

function [results] = test(k)
    [sentosaList, verisicolorList, virginicaList, sentosaTest, verisicolorTest, virginicaTest] = train(k);
    
    numTest = length(sentosaTest); % length of test list
    numAttr = 4; % number of attributes
    
    results = ones(numTest, 3); % init all values to pass
    
    %% Testing
    % if any attribute does not have a value that exists in the
    % model list, fail
            
    % sentosa testing
    for t = 1:numTest 
        for a = 1:numAttr
            results(t,1) = results(t,1) && any(sentosaTest(t,a) == sentosaList{a});
        end
    end
    
    % verisicolor testing
    for t = 1:numTest
        for a = 1:numAttr
            results(t,2) = results(t,2) && any(verisicolorTest(t,a) == verisicolorList{a});
        end
    end
    
    % virginica testing
    for t = 1:numTest
        for a = 1:numAttr
            results(t,3) = results(t,3) && any(virginicaTest(t,a) == virginicaList{a});
        end
    end
end