clc;
% Comment this if other files are to be examined
%processData = RcvData{1};
%processData = rawData;
%processData = compressedData;
processData = buffer;
%processData = target_buffer;

% Process selection switchs
FE_PLOT = 0;

% The format of the header: 0, expect a glitch
%                           1, don't have any specification

% Reply = RPLY_ID=*
%FE_SEARCH_CODE = [0,0, 0,1,0,1];

% Reply = RPLY_ID=FF
FE_SEARCH_CODE = [0,0, 0,1,0,1, 1,1,1,1,1,1,1,1, 0,1];
FE_SEARCH_RANGE = 5;

% Reply = RPLY_ID=FE
%FE_SEARCH_CODE = [0,0, 0,1,0,1, 1,1,1,1,1,1,1,0, 1,0];
%FE_SEARCH_RANGE = 4;

% Reply = RPLY_ACK
%FE_SEARCH_CODE = [0,0, 0,1,1,0, 0,1,0,1,0,1,0,1, 0,1];
%FE_SEARCH_RANGE = 4;

FE_FRAME_SIZE = 60;

%FE_BEAM_MIN = 124;
%FE_BEAM_MAX = 192;

FE_BEAM_MIN = 1;
FE_BEAM_MAX = 1;

%FE_LINEMIN = 800;
%FE_LINEMAX = 850;

FE_LINE_MIN = 1;
FE_LINE_MAX = 1280;

FE_ELEMENT_MIN = 1;
%FE_ELEMENT_MIN = 128;
%FE_ELEMENT_MAX = 128;
FE_ELEMENT_MAX = 192 * 4;

FE_ELEMENT_REPEAT = 1; % For movies without X-expansion
%FE_ELEMENT_REPEAT = 4; %For movies with X-expansion

% F = 4.0323MHz
FE_LINESTOP = 1280; % For movie data
%FE_LINESTOP = 1664; % For depth data

%FE_NOISE_BAR = 60;
%FE_DATA_MIN_AMP = 5;

%FE_NOISE_BAR = 0.001;
FE_NOISE_BAR = 1e-6;
%FE_DATA_MIN_AMP = 0.004;
FE_DATA_MIN_AMP = 1e-6;

% Preparation work
frameNumber = size(processData,3);
figureHandle = figure;

codeVerifyRange = size(FE_SEARCH_CODE,2);
FE_CODE_EXTEND = [ones(1,FE_SEARCH_RANGE), ...
    reshape([FE_SEARCH_CODE;ones(1,codeVerifyRange)],1,codeVerifyRange*2), ...
    ones(1, FE_FRAME_SIZE - codeVerifyRange*2 - FE_SEARCH_RANGE)];

% Invivo hack
%FE_CODE_EXTEND(33)=0;
%FE_CODE_EXTEND(34)=1;

% Two mote hack for the second
%FE_CODE_EXTEND = [1,1,1,1, 1,1,0,1, 0,1,0,1, 1,0,1,1, ...
%                  1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1, ...
%                  0,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1, ...
%                  1,1,1,1, 1,1,1,1, 1,1,1,1];

% Isolate symbols for 0 and 1
FE_LINSPACE = 1:60;
mZeroSymbolInd = FE_LINSPACE(FE_CODE_EXTEND == 0);
mOneSymbolInd = FE_LINSPACE(FE_CODE_EXTEND == 1);

% Sweeping across beams first
for i = FE_BEAM_MIN:FE_BEAM_MAX
    mBeamMaxEbN0 = 0;
    mBeamDepth = 0;
    mBeamElement = 0;
    mBeamMinBER = 1;
    disp(['Processing ray #',num2str(i)]);
    % Sweeping across elements
    for k = FE_ELEMENT_MIN : FE_ELEMENT_MAX
        % Sweeping into depth
        for j = FE_LINE_MIN : FE_LINE_MAX
            data = reshape( processData(j + (i-1) * FE_LINESTOP, k * FE_ELEMENT_REPEAT, :), frameNumber , 1);
            
            % Immediet rejection if considered as noise
            if(abs(max(data))<FE_NOISE_BAR)
                continue;
            end
            lFlag = 1;
            
            for iterCode = 1:codeVerifyRange
                if FE_SEARCH_CODE(iterCode) == 1
                    continue
                else
                    iter = FE_SEARCH_RANGE + (iterCode - 1) * 2;
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
                if (FE_PLOT == 1)
                    figure(figureHandle);
                    plot(data - linspace(data(1), data(end), 60)');
                    hold on;
                    plot(mNoiseAll);
                    hold off;
                    title(['Data at Beam # ', num2str(i), ', Element # ', ...
                        num2str(k), ', Depth ', num2str(j), ...
                        ' Eb/N0 = ', num2str(mEbN0), 'dB']);
                    key = waitforbuttonpress;
                end
                if (FE_PLOT == 0)
                    if mEbN0 > mBeamMaxEbN0
                        mBeamMinBER = mBER;
                        mBeamMaxEbN0 = mEbN0;
                        mBeamDepth = j;
                        mBeamElement = k;
                    end
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
end
close(figureHandle);