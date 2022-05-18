%% This script plots the example time frames, for demostration purposes
clc;
close all;

%% Configure the source file
FE_SOURCE_FILE = '../chicken_data/time_example.mat';

load(FE_SOURCE_FILE);

%% Configure the extention ratio
FE_EXTENTION_RATIO = 10;
FE_NR_FRAMES = 60;

%% Process
% Normalization
dataFFResponseBase = double(dataFFResponse(1));
dataFFResponse = double(dataFFResponse) - dataFFResponseBase;
dataFFResponse = dataFFResponse ./ dataFFResponseBase;

dataFFHelloBase = double(dataFFHello(1));
dataFFHello = double(dataFFHello) - dataFFHelloBase;
dataFFHello = dataFFHello ./ dataFFHelloBase;

dataFFNullBase = double(dataFFNull(1));
dataFFNull = double(dataFFNull) - dataFFNullBase;
dataFFNull = dataFFNull ./ dataFFNullBase;

dataFEResponseBase = double(dataFEResponse(1));
dataFEResponse = double(dataFEResponse) - dataFEResponseBase;
dataFEResponse = dataFEResponse ./ dataFEResponseBase;

dataFEHelloBase = double(dataFEHello(1));
dataFEHello = double(dataFEHello) - dataFEHelloBase;
dataFEHello = dataFEHello ./ dataFEHelloBase;

dataFENullBase = double(dataFENull(1));
dataFENull = double(dataFENull) - dataFENullBase;
dataFENull = dataFENull ./ dataFENullBase;

% Extend to square wave
dataFFResponse_extend = reshape(repmat(dataFFResponse, [1 10])', [FE_NR_FRAMES*FE_EXTENTION_RATIO, 1])';
dataFFHello_extend = reshape(repmat(dataFFHello, [1 10])', [FE_NR_FRAMES*FE_EXTENTION_RATIO, 1])';
dataFFNull_extend = reshape(repmat(dataFFNull, [1 10])', [FE_NR_FRAMES*FE_EXTENTION_RATIO, 1])';
dataFEResponse_extend = reshape(repmat(dataFEResponse, [1 10])', [FE_NR_FRAMES*FE_EXTENTION_RATIO, 1])';
dataFENull_extend = reshape(repmat(dataFENull, [1 10])', [FE_NR_FRAMES*FE_EXTENTION_RATIO, 1])';
dataFEHello_extend = reshape(repmat(dataFEHello, [1 10])', [FE_NR_FRAMES*FE_EXTENTION_RATIO, 1])';

%% Plot the figures
frames = 1 : FE_NR_FRAMES * FE_EXTENTION_RATIO;

figure;
plot(frames, dataFFResponse_extend);
axis([1 FE_NR_FRAMES * FE_EXTENTION_RATIO, -0.05 0.1]);
figure;
plot(frames, dataFFHello_extend);
axis([1 FE_NR_FRAMES * FE_EXTENTION_RATIO, -0.05 0.1]);
figure;
plot(frames, dataFFNull_extend);
axis([1 FE_NR_FRAMES * FE_EXTENTION_RATIO, -0.05 0.1]);
figure;
plot(frames, dataFEResponse_extend);
axis([1 FE_NR_FRAMES * FE_EXTENTION_RATIO, -0.05 0.1]);
figure;
plot(frames, dataFENull_extend);
axis([1 FE_NR_FRAMES * FE_EXTENTION_RATIO, -0.05 0.1]);
figure;
plot(frames, dataFEHello_extend);
axis([1 FE_NR_FRAMES * FE_EXTENTION_RATIO, -0.05 0.1]);