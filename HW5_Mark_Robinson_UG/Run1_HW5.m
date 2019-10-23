clear all;
close all;

rng(sum('MarkRobinson'))

load("264_optdigits.mat");

% split data between training and testing
[trainlabels,trainfeatures,testlabels,testfeatures] = splitData(class_label,data);
% grid search iteration count
n = 10;
% find the best cost and gamma values
[c,g,a,params] = gridSearch(trainlabels,trainfeatures,n);
% train the model using the best cost and gamma
model = train(trainlabels,trainfeatures,params);
% predict the number values
[predicted_label,cm] = predict(testlabels,testfeatures,model);
str = sprintf('Cost: %d, Gamma: %d, Acuraccy: %d',c,g,a)


% split data between training and testing
function [trainlabels,trainfeatures,testlabels,testfeatures] = splitData(class_label,data)
len = length(class_label);
%training data
trainlabels = class_label(1:len/2,:);
trainfeatures = data(1:len/2,:);
%testing data
testlabels = class_label(len/2+1:end,:);
testfeatures = data(len/2+1:end,:);
end

% perform grid search to get the best parameters
% try different cost and gamma values
function [c,g,accuracy,params] = gridSearch(trainlabels, trainfeatures,n)
max = [0,0,0];
params = '';
for c = linspace(2*10^-5,2*10^15,n)
    for g = linspace(2*10^-15,2*10^3,n)
        params = sprintf('-s 0 -t 0 -c %d -v 4 -g %d -q', c,g);
        curr = svmtrain(trainlabels, trainfeatures, params);
        if curr > max(3)
            max(1) = c;
            max(2) = g;
            max(3) = curr;
        end
    end
end
accuracy = max(3);
c = max(1);
g = max(2);
params = sprintf('-s 0 -t 0 -c %d -g %d -q', c,g);
end
    
function model = train(trainlabels,trainfeatures,params)
model = svmtrain(trainlabels, trainfeatures, params);
end

%test model on new data
function [predicted_label,cm] = predict(testlabels,testfeatures,model)
[predicted_label] = svmpredict(testlabels,testfeatures,model);
%display confusion matrix
cm = confusionchart(testlabels, predicted_label);
end