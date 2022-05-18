# Reconstruction scripts

## Overview

These scripts takes the receive data buffer (assuming B-mode imaging) from Verasonics Vantage Systems, reconstruct the images, and detect if there are any digitally modulated active motes within the field of view.

## Prerequists

- A complete RcvData structure from the Verasonics' MATLAB interface.
- TX focus, the organization of the RcvData (like number of raylines, number of frames, number of samples per rayline, etc.).

## Minimum Working Flow

- Set the environment variables in `reconstruction.m`.
	- FE_DATA_SET points to the `.mat` file with RcvData
	- FE_TARGET_FOLDER specifies the output folder
	- FE_TARGET_FILE specifies the name of the output `.mat` file
	- FE_SPEED_OF_SOUND is the sound speed in the medium of concern
	- FE_SAMPS_PER_SEC is the sampling frequency used to generate RcvData
	- FE_SPACING is the horizontal transducer spacing
	- FE_CENTER_FREQ is the center frequency of the ultrasound wave
	- FE_RANGE specifies the start and the end of each scan
	- FE_NR_RAYS specifies the number of scan lines in one frame
	- FE_DAS_CENTER is the offset of the center coordinate for delay-and-sum, should be 0.
	- FE_DAS_SPAN specifies the number of receive elements used for delay-and-sum
	- FE_FILTER_BW specifies the bandwidth of the low pass filter used to clean up the ultrasound image in the depth direction
	- FE_IMAGE_MAX_VAL specifies the maximum intensity of the end B-mode image
	- FE_INITIAL_IMAGE_CROP is obsolete, set to 0
	- FE_END_IMAGE_CROP is obsolete, set to 0
	- FE_FOCUS is the receive focus in meter. It can be commented out and overriden in a master loop, if one needs multiple receive focus to reconstruct one same image.

- Run `reconstruction.m`, and locate the output data.

- If multiple receive foci are used, an additional `compressCompoundFrame.m` script is required to generate the final B-mode image. The environment variables are described as follows:
	- FE_FILES specifies a list of input files
	- FE_FOCI specifies a list of foci, in the order identical to the input files
	- FE_TRANS specifies the transision width between B-mode images using different foci
	- FE_OUTPUT_FILE specifies the name of the output file
	- FE_BUFFER_SIZE_RAYS specifies the number of scan lines in one frame, or number of samples on the X-axis
	- FE_BUFFER_SIZE_DEPTH specifies the number of samples on the Y-axis
	- FE_BUFFER_SIZE_FRAMES specifies the number of frames
	- FE_SCALE_X and FE_SCALE_Y specifies the scale factor, 4:1 is what makes pixels closer to their actual scale
	- FE_INTENSITY_LIN_SCALE (a) and FE_INTENSITY_LOG_SCALE (b) are the compression factor for intensity re-scaling: output = a * log10 (1 + b * input) / log10 (1 + b).
	- FE_AGC_LOG_FACTOR is the log factor in automatic gain control

- Run `aumplitudeZoom.m` for data detection in time domain. The script uses the variable `buffer` by default.

- Run `sequencyConcat.m` if multiple movie clips needs to be concatenated together.

- Run `makeMovie.m` for final image stream genenration.

## Files and Dependency
- reconstruction.m
	- delayAndSum.m
	- logcompression.m
	- gaussianFilter2.m
		- gaussian.m
	- envelopeDetection.m
- compressCompoundFrame.m
	- taperWeights.m
	- logcompression.m
- amplitudeZoom.m
- sequenceConcat.m
- makeMovie.m
