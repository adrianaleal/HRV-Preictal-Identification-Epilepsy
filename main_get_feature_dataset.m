fclose all; clear; close all; clc;
set(groot, 'DefaultAxesFontSize',11,'defaultTextFontSize',11)
set(groot, 'DefaultAxesTickLabelInterpreter','tex');
set(groot, 'DefaultLegendInterpreter','tex');
set(groot, 'DefaultTextInterpreter','tex')


% define the path to the folder containing the features extracted for each
% patient and seizure:
feature_folder_path = fullfile(cd, 'ResultsFeatureExtraction');


% load variable patients_info_final:
load('patients_info_preictal_study_240min_before_seiz')

% open folder containing the concatenated feature dataset:
concat_feat_folder_path = fullfile(cd,'FeatureDataset');
if ~exist(concat_feat_folder_path, 'dir')
    mkdir(concat_feat_folder_path)
end

% add utils folder to the path:
functionsFolder = 'utils';
folder2savePath = fullfile(cd, functionsFolder);
if exist(folder2savePath, 'dir')
    % Add that folder plus all subfolders to the path.
    addpath(genpath(folder2savePath));
end


load(fullfile(concat_feat_folder_path, 'structureData.mat'))
variables2load = {'feat_names2analyse', 'n_wins', 'n_seizures', ...
    'compTimeTable', 'seizure_struct'}';
for ii = 1:numel(variables2load)
    eval([variables2load{ii} ' = structureData.' variables2load{ii} ';'])
end
clear structureData

load(fullfile(concat_feat_folder_path, 'feature_dataset_240min_before_seizure_3D.mat'), ...
    'feature_dataset_240min_before_seizure_3D')
load(fullfile(concat_feat_folder_path, 'feature_dataset_240min_before_seizure_all_feat.mat'), ...
    'feature_dataset_240min_before_seizure_all_feat')
load(fullfile(concat_feat_folder_path, 'feature_dataset_240min_before_seizure.mat'), ...
    'feature_dataset_240min_before_seizure')

seizure_names = {seizure_struct(:).seizure_name}';
index_nonempty = find(~cellfun(@isempty,seizure_names));
seizure_names = seizure_names(index_nonempty);

% get the patients' names to initialize the structure to save the results
C = cellfun(@(x)strsplit(x, '_' ), seizure_names, 'UniformOutput', false);
seizure_names_separated = vertcat(C{:});
pats_name = unique(seizure_names_separated(:,2),'stable');
n_pat = numel(pats_name);


% PLOT FEATURES OVER TIME *************************************************


% choose how many features you want to observe in plot: 
% check the features' names in feat_names2analyse
feat_names = {'RRMean', 'LF_POWER', 'SampEn'}

% define the patient and seizure inside the function
plotSignal2Features(feat_names, patients_name, ...
    seizure_names_separated(:,2), feature_folder_path, patients_info_final)




