
%%% This code takes structured light captured images and gives the decoded 
%%% column/row indices.

%%% This is the script file (with the parameters) for the function
%%% CombinedDecode.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; pack; clc; 

%%%%%%%%%%%%%%%% Input data directory and file naming %%%%%%%%%%%%%%%%%%%%%

% Input Data directory. For directory structure, see README.doc
% The data should be in 4 sub-directories, one for each set of codes. An
% example is included in '..\..\Experiments\data\Bowl'.
%调制后的图片目录
dataDirname     = ['..\..\Experiments\data\Bowl'];    

% Directory which contains the projected images. These directories contain
% the information about projected patterns required for decoding. This
% directory has the same sub-directory structure as the captured data. 
%编码图目录
permDirname     = ['..\..\Patterns'];

% Length of the filenames. For example, if the names are 01.pgm,
%文件名的长度
% 02.pgm,..., the indexlength is 2. 
indexLength     = 2;
imSuffix        = ['.pgm'];         % Image suffix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%% Defining parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Camera and projector parameters
projDim         = [768 1024];          % Number of projector rows and columns投影图片的分辨率
camDim          = [2000 2400];      % Number of camera rows and columns相机拍摄图片的分辨率



%%% Reconstruction parameters.
ShadowThresh    = 0.0;   % Threshold for culling shadow pixels. The larger the value, the more aggressive is the culling. Typical values between [0,0.1]. If it is set to zero - so no pixels will be culled. 
%剔除阴影像素的阈值。值越大，剔除的效果越强。小于阈值的像素不必删除。
medfiltParam    = [3 3];    % Size of filter for pre-filtering the correspondence maps before applying the consistency check. Typical values: [3x3] -- [5x5]. If too many holes left in the final image, use 5x5. 
%中型滤波器的尺寸大小。一般从3*3到5*5.
DiffThresh      = 3;   % Difference threshold (in pixels) - below which the decoded column values for different codes are considered the same. See paper for details. 
%差异阈值，相差小于该值的两个解码值可以认为没有区别。
HoleFillFlag    = 1;     % If (software) hole-filling is performed in post-processing for error-pixels. Make this zero if no holes are being formed in the correspondence map. 
%如果后期处理没有填补像素的操作，该值为1，否则为0.
medfiltHoleFill = [17 17];     % Size of the neighborhood for Hole Filling. Typical values: [9x9] -- [25x25]. Use larger values if too many holes are left in the final correspondence map. Holefilling affects only the error pixels. 
%填补空像素的滤波器尺寸大小，从9*9到25*25，需要填补的面积越大滤波器体积越大。这一操作仅仅针对错误像素。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% Recovering the correspondences %%%%%%%%%%%%%%%%%%%%%%

% IC is the correspondence map
tic;
[IC]     = CombinedDecode(dataDirname, permDirname, indexLength, camDim(1), camDim(2), imSuffix, ShadowThresh, medfiltParam, DiffThresh, HoleFillFlag, medfiltHoleFill);
toc;
%%% Saving the correspondence map
save([dataDirname, '\DecodedIndices.mat'], 'IC');
%%% Show the result
figure;imagesc(IC);colormap(jet(256));colorbar

%jet256 图像颜色情况

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%