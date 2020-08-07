fclose all; clear; close all; clc;
set(groot, 'DefaultAxesFontSize',11,'defaultTextFontSize',11)
set(groot, 'DefaultAxesTickLabelInterpreter','tex');
set(groot, 'DefaultLegendInterpreter','tex');
set(groot, 'DefaultTextInterpreter','tex')


cd ..
outer_folder_path = cd;
% load variable patients_info_final:
load('patients_info_preictal_study_240min_before_seiz')
cd('Feature Redundancy Study')
    
dataset_folder_path = fullfile(outer_folder_path, 'FeatureDataset');
if ~exist(dataset_folder_path, 'dir')
    mkdir(dataset_folder_path)
end

% load feature data>
load(fullfile(dataset_folder_path, 'structureData.mat'))
variables2load = {'feat_names2analyse', 'n_wins', 'n_seizures', ...
    'compTimeTable', 'seizure_struct'}';
    
for ii = 1:numel(variables2load)
    eval([variables2load{ii} ' = structureData.' variables2load{ii} ';'])
end
clear structureData

load(fullfile(dataset_folder_path, 'feature_dataset_240min_before_seizure_3D.mat'), ...
    'feature_dataset_240min_before_seizure_3D')

seizure_names = {seizure_struct(:).seizure_name};

% get the patients' names to initialize the structure to save the results
C = cellfun(@(x)strsplit(x, '_' ), seizure_names, 'UniformOutput', false);
seizure_names_separated = vertcat(C{:});
pats_name = unique(seizure_names_separated(:,2),'stable');
n_pat = numel(pats_name);
clear C pats_name 


%% Feature redundancy study
% The feature redundancy study was performed by using Pearson's correlation
% coefficient and average mutual information

removeSeizures = 0;
if removeSeizures==1
    folder2save = 'ResultsFeatureRedundancyRemovedSeizures';
else
    folder2save = 'ResultsFeatureRedundancy';
end

folder2savePath = fullfile(cd, folder2save);
if ~exist(folder2savePath, 'dir')
    mkdir(folder2savePath)
end

functionsFolder = 'FunctionsFeatureRedundancy';
folder2savePath = fullfile(cd, functionsFolder);
if exist(folder2savePath, 'dir')
    % Add that folder plus all subfolders to the path.
    addpath(genpath(folder2savePath));
end

functionsFolder = 'utils';
folder2savePath = fullfile(outer_folder_path, functionsFolder);
if exist(folder2savePath, 'dir')
    % Add that folder plus all subfolders to the path.
    addpath(genpath(folder2savePath));
end

chosenDim = 'windows' % other option is 'seizures'
results_feat_selection = feature_redundancy_assessment(...
    feature_dataset_240min_before_seizure_3D, feat_names2analyse, ...
    folder2save, seizure_names_separated, removeSeizures, chosenDim);

if exist(folder2savePath, 'dir')
    % Remove that folder plus all subfolders to the path.
    rmpath(genpath(folder2savePath))
end



