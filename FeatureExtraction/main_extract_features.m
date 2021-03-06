% Example of how to run feature extraction on a supplied RR interval series

fclose all; clear; close all; clc;


% *****************************************************************
% to compute the classical scalar HRV parameters (SDNN, pNN50, RMSSD)
% there is no need for the instantaneous heart rate, only inter-beat RR
% intervals

%% Load examples of RR interval series 
% (that were used in Supplementary Material in Figures S5, S6 and S7 and 
% that correspond to the first seizure of patient 8902).

load_window = 0;

if load_window
    % RR interval series located from 78 to 73 minutes before seizure onset
    load('RRI_series_segment_pat_8902_seiz_1_win_1940.mat')
    % corresponding irregularly-sampled time vector
    load('time_RRI_series_segment_pat_8902_seiz_1_win_1940.mat')
    
    RRI_series_segment = RRI_series_segment_pat_8902_seiz_1_win_1940;
    time_RR_intervals = time_RRI_series_segment_pat_8902_seiz_1_win_1940;
else
    % RR interval series located from 26 to 21 minutes before seizure onset
    load('RRI_series_segment_pat_8902_seiz_1_win_2569.mat')
    % corresponding irregularly-sampled time vector
    load('time_RRI_series_segment_pat_8902_seiz_1_win_2569.mat')
    
    RRI_series_segment = RRI_series_segment_pat_8902_seiz_1_win_2569;
    time_RR_intervals = time_RRI_series_segment_pat_8902_seiz_1_win_2569;
end

%%
plotFigure = 1; % flag to plot figures for each group of features

% add FunctionsFeatureExtraction folder to the path
addpath(genpath(fullfile(cd, 'HRVFeatures')))

%% Time-domain features

hrv_td = time_features(RRI_series_segment)

%% Frequency-domain features

[hrv_fd, interp_RRI_series_segment] = frequency_features(RRI_series_segment,...
    time_RR_intervals, plotFigure);
hrv_fd

%% Nonlinear features

%% Poincar� plot

[SD1, SD2, SD1toSD2] = poincare_plot(RRI_series_segment, plotFigure)

%% Detrended Fluctuation Analysis
% - alpha1: Log-log slope of DFA in the low-scale region. [4 11]
% - alpha2: Log-log slope of DFA in the high-scale region. [11, 64]

scale_range = [4 11; 11 64];
[segment_size_vec, n_segment_vec, F, alpha_vec] = ...
    monofractal_detrended_fluctuation_analysis(RRI_series_segment, scale_range, ...
    plotFigure);

DFA_alpha1 = alpha_vec(1)
DFA_alpha2 = alpha_vec(2)


%% normalize signal

if ~isempty(interp_RRI_series_segment)
    
    fs = 4;
    sig2analyse = interp_RRI_series_segment;
    sig_norm = (sig2analyse-mean(sig2analyse))/std(sig2analyse); % Varsavsky2011
    
    %% Approximate entropy
    % estimates the approximate entropy of the uniformly sampled
    % time-domain signal X by reconstructing the phase space
    % The default value of Radius is, 0.2*variance(X), if X has a
    % single column.
    % m default value is 2
    
    ApEn = approximateEntropy(sig_norm)
    
    %% Sample entropy
    
    m = 2;
    r_tolerance = 0.2;
    SampEn = sample_entropy(sig_norm, m, r_tolerance)
    
    %% Phase Space Reconstruction
    % (1) Time delay was estimated using the first local minimum of the average
    % mutual information (using the default value of 'HistogramBins' = 10)
    % The time delay was estimated using the default 'MaxLag' = 10
    % (2) Embedding dimension was estimated using the False Nearest Neighbor
    % algorithm (using the default value of 'PercentFalseNeighbors' = 0.1)
    % The embedding dimension was estimated using the default 'MaxDim' = 5
    
    % phaseSpaceReconstruction requires that sig_norm is uniformly sampled
    [attractorPSR, tauPSR, eDimPSR] = phaseSpaceReconstruction(sig_norm);
    
    if plotFigure
        figure()
        phaseSpaceReconstruction(sig_norm, tauPSR, eDimPSR);
    end
    
    %% Largest Lyapunov Exponent
    
    expansion_range = [1 30];
    LLE = lyapunovExponent(sig_norm, fs, 'Dimension', eDimPSR, ...
        'Lag', tauPSR, 'ExpansionRange', expansion_range)
    
    %% Correlation dimension
    % estimates the correlation dimension of the uniformly sampled
    % time-domain signal
    Np = 100;
    min_radius = 0.05;
    CD = correlationDimension(sig_norm, 'Dimension', eDimPSR, ...
        'Lag', tauPSR, 'MinRadius', min_radius, 'NumPoints', Np)
    
    %%
    if plotFigure
        
        lyapunovExponent(sig_norm, fs, 'Dimension', eDimPSR, ...
            'Lag', tauPSR, 'ExpansionRange', expansion_range);
        % MinSeparation is the threshold value used to find the nearest
        % neighbor i* for a point i to estimate the largest Lyapunov exponent.
        % 'MinSeparation', ceil(fs/max(meanfreq(X,fs)))
        f1 = gcf;
        correlationDimension(sig_norm, 'Dimension', eDimPSR, ...
            'Lag', tauPSR, 'MinRadius', min_radius, 'NumPoints', Np);
        f2 = gcf;
        
        
        figure()
        set(gcf,'units','normalized','outerposition',[0 0 0.6 1])
        subplot(221)
        if eDimPSR==2
            plot(attractorPSR(:,1), attractorPSR(:,2))
            xlabel('x(k)')
            ylabel(['x(k-' num2str(tauPSR) ')'])
        elseif eDimPSR==3
            % A three-dimensional embedding uses a delay of 2*tau for the third
            % dimension.
            plot3(attractorPSR(:,1), attractorPSR(:,2), attractorPSR(:,3))
            xlabel('x(k)')
            ylabel('x(k-\tau)')
            zlabel('x(k-2\tau)')
        end
        box on
        
        s2 = subplot(222);
        copy_figure(f1, s2)
        
        s3 = subplot(223);
        copy_figure(f2, s3)
        
    end
    
    %% Recurrence Quantification Analysis
    
    [hrv_rqa, ~, ~] = recurrenceAnalysis(sig_norm, tauPSR, eDimPSR, ...
        plotFigure, attractorPSR);
    
end


%% plot Figure S8 in Supplementary Material 

% select the features (see the names in feat_names2analyse) that you want
% to observe in figure:
feat_names = {'RRMean', 'LF_POWER', 'SampEn'}
patient_name = '8902';
plotSignal2Features(feat_names, patient_name)






