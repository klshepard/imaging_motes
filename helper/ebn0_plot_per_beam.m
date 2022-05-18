clc;
% Comment this if other files are to be examined
%processData = RcvData{1};
processData = rawData;
%processData = compressedData;

%% Target file name
FE_TARGET_FILE = 'chicken/beam_2.mat';

% Process selection switchs
FE_PLOT = 0;

% The format of the header: 0, expect a glitch
%                           1, don't have any specification

% Reply = RPLY_ID=*
%FE_SEARCH_CODE = [0,0, 0,1,0,1];

% Reply = RPLY_ID=FF
%FE_SEARCH_CODE = [0,0, 0,1,0,1, 1,1,1,1,1,1,1,1, 0,1];
%FE_SEARCH_RANGE = 6;

% Reply = RPLY_ID=FE
FE_SEARCH_CODE = [0,0, 0,1,0,1, 1,1,1,1,1,1,1,0, 1,0];
FE_SEARCH_RANGE = 4;

% Reply = RPLY_ACK
%FE_SEARCH_CODE = [0,0, 0,1,1,0, 0,1,0,1,0,1,0,1, 0,1];
%FE_SEARCH_RANGE = 4;

FE_FRAME_SIZE = 60;

FE_BEAM_MIN = 128;
FE_BEAM_MAX = 192;

FE_LINEMIN = 1;
FE_LINEMAX = 1280;

FE_NR_ELEMENTS = 128;

% F = 4.0323MHz
FE_LINESTOP = 1280;

FE_NOISE_BAR = 60;
FE_DATA_MIN_AMP = 5;

% Preparation work
frameNumber = size(processData,3);

codeVerifyRange = size(FE_SEARCH_CODE,2);
FE_CODE_EXTEND = [ones(1,FE_SEARCH_RANGE), ...
    reshape([FE_SEARCH_CODE;ones(1,codeVerifyRange)],1,codeVerifyRange*2), ...
    ones(1, FE_FRAME_SIZE - codeVerifyRange*2 - FE_SEARCH_RANGE)];

% Isolate symbols for 0 and 1
FE_LINSPACE = 1:60;
mZeroSymbolInd = FE_LINSPACE(FE_CODE_EXTEND == 0);
mOneSymbolInd = FE_LINSPACE(FE_CODE_EXTEND == 1);

mFinalBuffer = zeros(FE_LINEMAX - FE_LINEMIN + 1, FE_NR_ELEMENTS, FE_BEAM_MAX - FE_BEAM_MIN + 1);

% Sweeping across beams first
for i = FE_BEAM_MIN:FE_BEAM_MAX
    % Initialize the Eb/N0 plot buffer
    mPlotOfThisFrame = zeros(FE_LINEMAX - FE_LINEMIN + 1, FE_NR_ELEMENTS);
    
    mBeamMaxEbN0 = 0;
    mBeamDepth = 0;
    mBeamElement = 0;
    mBeamMinBER = 1;
    disp(['Processing ray #',num2str(i)]);
    % Sweeping across elements
    for k = 1 : FE_NR_ELEMENTS
        % Sweeping into depth
        if (i <= FE_NR_ELEMENTS / 2)
            mCurrentColIndex = k;
        else
            mCurrentColIndex = k - (i - FE_NR_ELEMENTS / 2);
            if (mCurrentColIndex < 0)
                mCurrentColIndex = mCurrentColIndex + FE_NR_ELEMENTS;
            end
        end
        for j = FE_LINEMIN : FE_LINEMAX
            data = reshape( processData(j + (i-1) * FE_LINESTOP, k, :), frameNumber , 1);
            
            % Immediet rejection if considered as noise
            if(abs(max(data))<FE_NOISE_BAR)
                continue;
            end
            lFlag = 1;
            
            for iterCode = 1:codeVerifyRange
                if FE_SEARCH_CODE(iterCode) == 1
                    continue
                else
                    iter = FE_SEARCH_RANGE + (iterCode - 1)*2;
                    if((data(iter+1)-data(iter)) * (data(iter+2)-data(iter+1)) >= 0)
                        lFlag = 0;
                        continue;
                    end
                    if(abs(data(iter+1)-data(iter)) <= FE_DATA_MIN_AMP)
                        lFlag = 0;
                        continue;
                    end
                end
            end
            if (lFlag == 1)
                data = double(data);
                mZeros = data(mZeroSymbolInd);
                mOnes = data(mOneSymbolInd);
                mNoiseAll = [mZeros - mean(mZeros); mOnes - mean(mOnes)];
                mSigAmp = abs(mean(mZeros) - mean(mOnes));
                mEb = (mSigAmp / 2)^2;
                mN0 = var(mNoiseAll,1);
                mBER = normpdf(sqrt(mEb/mN0),0,1);
                mEbN0 = 10*log10(mEb/mN0);
                % Only plot when such data is found
                if mEbN0 > 0
                    mPlotOfThisFrame(j, mCurrentColIndex) = mEbN0;
                end
            end
        end
    end
    if mBeamMaxEbN0 ~= 0
        disp(['Maximum Eb/N0 found is ', num2str(mBeamMaxEbN0), ...
            ' (Associated BER = ', num2str(mBeamMinBER), ')', ...
            ', at Element ', num2str(mBeamElement), ...
            ', Depth ', num2str(mBeamDepth)]);
    end
    mFinalBuffer(:, :, i - FE_BEAM_MIN + 1) = mPlotOfThisFrame;
end

normalized_buffer = mFinalBuffer ./ max(max(max(mFinalBuffer)));
save(FE_TARGET_FILE, 'normalized_buffer');