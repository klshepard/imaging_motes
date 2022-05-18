clc;
% Comment this if other files are to be examined
%rawData = RcvData{1};
%rawData = target_buffer(:, :, 1:60);
%rawData = target_buffer;
rawData = buffer(:, :, 1:60);

% Normalization
rawData = rawData ./ max(max(max(rawData))) * 255;

% The format of the header: 0, expect a glitch
%                           1, don't have any specification
%FE_SEARCH_CODE = [0,0, 0,1,1,0, 0,1,0,1,0,1,0,1];
%FE_SEARCH_CODE = [0,0, 0,1,0,1, 1,1,1,1,1,1,1,1,0,1];
FE_SEARCH_CODE = [0,0, 0,1,0,1];
%FE_SEARCH_CODE = [0,0, 0,1,0,1, 1,1,1,1,1,1,1,0];
FE_SEARCH_RANGE = [6];

[size_y, size_x, frame_number] = size(rawData);

FE_NOISE_BAR = 5e-3;
FE_DATA_MIN_AMP = 0.05;

% Preparation work
figureHandle = figure;

codeVerifyRange = size(FE_SEARCH_CODE,2);

%% Config the scan range
%FE_SCAN_X_START = (141 - 128) * 4 + 1;
%FE_SCAN_X_STOP = (151 - 128) * 4;
FE_SCAN_X_START = 1;
FE_SCAN_X_STOP = 192;
FE_SCAN_X_FACTOR = 4;
FE_SCAN_Y_START = 1;
FE_SCAN_Y_STOP = 1280;

% Sweeping across elements
for k = (FE_SCAN_X_START - 1) * FE_SCAN_X_FACTOR + 1 : FE_SCAN_X_FACTOR : FE_SCAN_X_STOP * FE_SCAN_X_FACTOR
    % Sweeping into depth
    for j = FE_SCAN_Y_START : FE_SCAN_Y_STOP
        data = reshape( rawData(j, k, :), frame_number , 1);

        % Immediet rejection if considered as noise
        if(abs(max(data))<FE_NOISE_BAR)
            continue;
        end
        lFlag = 1;

        for iterStart = FE_SEARCH_RANGE
            for iterCode = 1:codeVerifyRange
                if FE_SEARCH_CODE(iterCode) == 1
                    continue
                else
                    iter = iterStart + (iterCode - 1)*2;
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
            % Only plot when such data is found
            if (lFlag == 1)
                figure(figureHandle);
                data = data - data(1);
                plot(data);
                title(['Data at Beam # ', num2str(k), ', Depth ', num2str(j)]);
                key = waitforbuttonpress;
                continue;
            end
        end
    end
end
close(figureHandle);