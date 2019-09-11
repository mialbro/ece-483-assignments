clc; close all; clear all;

%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: C:\Users\mial2\Desktop\ece483\HW2\datatraining.txt
%
% Auto-generated by MATLAB on 30-Aug-2019 14:03:25

%% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 8);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["index", "date", "Temperature", "Humidity", "Light", "CO2", "HumidityRatio", "Occupancy"];
opts.VariableTypes = ["double", "datetime", "double", "double", "double", "double", "double", "double"];
opts = setvaropts(opts, 2, "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
datatraining = readtable("C:\Users\mial2\Desktop\ece483\HW2\datatraining.txt", opts);
clear opts

% unseen data
opts = delimitedTextImportOptions("NumVariables", 8);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["index", "date", "Temperature", "Humidity", "Light", "CO2", "HumidityRatio", "Occupancy"];
opts.VariableTypes = ["double", "datetime", "double", "double", "double", "double", "double", "double"];
opts = setvaropts(opts, 2, "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
unseenData = readtable("C:\Users\mial2\Desktop\ece483\HW2\datatest.txt", opts);


%% Clear temporary variables
features = opts.VariableNames;

% seed random generator
 rng(sum('MarkRobinson'))
% testing data
unseenData = unseenData{2:end, 3:end};
% shuffle the testing data
unseenData = unseenData(randperm(size(unseenData,1)),:);
unseenOcc = unseenData(1:end,end);

%training data
datatraining = datatraining{2:end, 3:end};
% shuffle the training data
datatraining = datatraining(randperm(size(datatraining,1)),:);
occupied = datatraining(1:end,end);

k = 10;
datapoints = length(datatraining);
foldindices = zeros(k+1,1); % represents the start of a new bucket

% create buckets
for index = 1:k+1 % create the buckets
    if index-1 <= mod(datapoints, k)
        if index == 1
            foldindices(index) = 1;
        else
            foldindices(index) = foldindices(index-1)+(floor((datapoints/k))+1);
        end
    else
    	foldindices(index) = foldindices(index-1)+(floor(datapoints/k));
    end
end

% iterate each class and train the classifiers for each feature
for class = 1:length(features)-3
    thresholds = zeros(k,1);
    testSpec = zeros(k,1);
    testSens = zeros(k,1);
    testErr = zeros(k,1);
    auc = zeros(k,1);
    % iterate each of the fold -> alternate the testing (validation) set
    hold on
    if class == length(features)-3
        subplot(3,2,[class,class+1])
    else
        subplot(3,2,class)
    end
    for f = 1:k
        spec = zeros(datapoints,1);
		sens = zeros(datapoints,1);
        far = zeros(datapoints,1);
        err = zeros(datapoints,1);
        % the testing (validation) set is at the front
        if f == 1
            training = datatraining(foldindices(f+1):end, class);
            trainOcc = occupied(foldindices(f+1):end);
        % the testing (validation) set is at the end
        elseif f == k
            training = datatraining(1:foldindices(f)-1, class);
            trainOcc = occupied(1:foldindices(f)-1);
        else
            % the testing (validation) set is in the center (kinda)
            training = [datatraining(1:foldindices(f)-1, class) ; datatraining(foldindices(f+1):end, class)];
            trainOcc = [occupied(1:foldindices(f)-1) ; occupied(foldindices(f+1):end)];
        end
        % testing (validation) set
        testing = datatraining(foldindices(f):foldindices(f+1)-1, class); % For validation
		testOcc = occupied(foldindices(f):foldindices(f+1)-1);
        
        % find the best DECISION BOUNDARY given this training and testing set
        ths = linspace(min(training),max(training),datapoints);
        for x = 1:length(ths)
            % find the best decision boundary for this fold
            [sens(x), spec(x), far(x), err(x)] = getErr(training, trainOcc, ths(x));
        end
   
        scatter(far,sens)
        auc(f) = trapz(far,sens);
        
        % get the index of the lowest error
		[minErr, errI] = min(err);
        % get the corresponding threshold for the lowest error
		thresholds(f) = ths(errI);
        % try the threshold on the testing set
        [testSens(f),testSpec(f),testErr(f)] = getErr(testing,testOcc,thresholds(f));
    end
    
    hold off
    title(['', string(features(class+2))]);
    xlabel('1-Specificity') 
    ylabel('Sensitivity')  
    
    % get the average of the thresholds
    th = mean(thresholds);
    % get the average of the errors
    avgErr = mean(minErr);
    % try the threshold on unseen data
    [sens,spec,far,err] = getErr(unseenData,unseenOcc,th);
    fprintf('class = %s\naverage error = %.8f\nfinal error = %.8f\nthreshold = %.8f\nauc = %.8f\n\n',string(features(class+2)),avgErr,err,th,-1*mean(auc))
end

function [sens, spec, far, err] = getErr(dataset, occupied, th)
	tp = 0;
    fp = 0;
    tn = 0;
    fn = 0;
    % see how well the current threshold performs on the data
    for y = 1:length(dataset)
        % we classify as occupied
        if dataset(y) >=  th
            if occupied(y) == 1
                tp = tp + 1;
            else
                fp = fp + 1;
            end
        else
            if occupied(y) == 0
            		tn = tn + 1;
            else
              	fn = fn + 1;
            end
        end
    end
    % gives us the error for the given threshold
    sens = tp/(tp+fn);
	spec = tn/(tn+fp);
    far = fp/(fp+tn);
    err = (fn+fp)/length(dataset);
end