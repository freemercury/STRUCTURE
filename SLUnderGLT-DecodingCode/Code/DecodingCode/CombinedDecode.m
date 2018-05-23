
%%% This function takes structured light captured images and gives the
%%% decoded column/row indices according to the algorithm given in the
%%% paper 'Structured Light 3D Scanning in the Presence of Global
%%% Illumination, CVPR 2011'. 

%%% The definitions of the arguments (and typical values) are given in the 
%%% script file FullDecodingCode.m

%%% IC is the output -- projector column correspondences for each camera pixel. 
%%% IC�����������ͶӰ
%%% IC is a matrix with the same size as the captured images. 
%%% IC�Ǻ�����ͼƬ������ͬ�ߴ�ľ���



function [IC]   = CombinedDecode(dirname, permDirnameBase, indexLength, nr, nc, imSuffix, ShadowThresh, medfiltParam, DiffThresh, HoleFillFlag, medfiltHoleFill)


%%%%%%%%%%%% Compute correspondences for each of the four codes %%%%%%%%%%%


%%%%%%%%%%%%%%% 1) Conventional Gray 

% Captured image directory and patterns directory 
dirnameRegularGray     = [dirname, '\ConventionalGray'];
permDirname     = [permDirnameBase, '\ConventionalGray'];
load([permDirname, '\permcol.mat']);        % Loading the permutation file. 
%���������ļ�

% Indices for the captured images. The code assumes that the images are
% numbered from 1:2:19, with the inverse images numbered as 2:2:20. 
% Li�����Ϊ������ͼƬ��Li�����Ϊż��
ColImageIndices    = [1:2:19];                                         

%����
[ICRegularGray, IDiff1RegularGray]   = bindecodePerm(dirnameRegularGray, indexLength, permcol, nr, nc, ColImageIndices, imSuffix);
ICRegularGray(IDiff1RegularGray < ShadowThresh) = 0;            
% Removing shadow/dark pixels ���IDiff1�����ֵС����Ӱ��ֵ���򱻶���Ϊ0.
ICRegularGray   = medfilt2(ICRegularGray, medfiltParam);        
% pre-filtering with a median filter ������ֵԤ�˲�
clear IDiff1RegularGray 



%%%%%%%%%%%%%%% 2) Max-Min-SW Gray 

% Captured image directory and patterns directory
dirnameMaxMinSWGray    = [dirname, '\MaxMinSWGray'];
permDirname          = [permDirnameBase, '\MaxMinSWGray'];
load([permDirname, '\permcol.mat']);         % Loading the permutation file. 

ColImageIndices                                 = [1:2:19];           


[ICMaxMinSWGray, IDiff1MaxMinSWGray]            = bindecodePerm(dirnameMaxMinSWGray, indexLength, permcol, nr, nc, ColImageIndices, imSuffix);
ICMaxMinSWGray(IDiff1MaxMinSWGray < ShadowThresh)= 0;                                            % Removing shadow/dark pixels
ICMaxMinSWGray                                  = medfilt2(ICMaxMinSWGray, medfiltParam);         % pre-filtering with a median filter
clear IDiff1MaxMinSWGray 




%%%%%%%%%%%%%%% 3) XOR-04 

% Captured image directory and patterns directory
dirnameXORGray04                                = [dirname, '\XOR04'];
permDirname                                     = [permDirnameBase, '\XOR04'];
load([permDirname, '\permcol.mat']);              % Loading the permutation file. 

ColImageIndices    = [1:2:19];           
% Indices for the base-plane image and the inverse base-plane image. 
% ��ʮ������Ϊbase pattern ʮ������Ϊ���ķ�תͼ��
ColImageBaseIndices     = [17:18];


[ICXORGray04, IDiff1XORGray04]    = bindecodePermXOR(dirnameXORGray04, permcol, nr, nc, ColImageIndices, ColImageBaseIndices, imSuffix);
ICXORGray04(IDiff1XORGray04 < ShadowThresh)     = 0;         % Removing shadow/dark pixels
ICXORGray04      = medfilt2(ICXORGray04, medfiltParam);        % pre-filtering with a median filter
clear IDiff1XORGray04



%%%%%%%%%%%%%%% 4) XOR-02 

% Captured image directory and patterns directory
dirnameXORGray02         = [dirname, '\XOR02'];
permDirname         = [permDirnameBase, '\XOR02'];
load([permDirname, '\permcol.mat']);                                                            % Loading the permutation file. 

ColImageIndices                     = [1:2:19];           
% Indices for the base-plane image and the inverse base-plane image. 
ColImageBaseIndices                 = [19:20];


[ICXORGray02, IDiff1XORGray02]        = bindecodePermXOR(dirnameXORGray02, permcol, nr, nc, ColImageIndices, ColImageBaseIndices, imSuffix);
ICXORGray02(IDiff1XORGray02 < ShadowThresh)     = 0;                                            % Removing shadow/dark pixels
ICXORGray02           = medfilt2(ICXORGray02, medfiltParam);          % pre-filtering with a median filter
clear IDiff1XORGray02


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








%%%%%%%% Applying the consistency check. For details, see the paper %%%%%%%
%%%%%%%%%%%%����һ���Լ��%%%%%%%%%

IC       = zeros(size(ICRegularGray));           %%% Final Combined Correspondence Map ���յ��ں�map
ICMask     = zeros(size(ICRegularGray));           %%% Temporary variable �м����



%%% Case analysis.

% Case 0: All codes are different
ICMask(abs(ICRegularGray - ICMaxMinSWGray)>DiffThresh & abs(ICRegularGray - ICXORGray04)>DiffThresh & abs(ICRegularGray - ICXORGray02)>DiffThresh & abs(ICMaxMinSWGray - ICXORGray04)>DiffThresh & abs(ICMaxMinSWGray - ICXORGray02)>DiffThresh & abs(ICXORGray04 - ICXORGray02)>DiffThresh) = 0;

% Case 1: Both the XORs are the same
ICMask(abs(ICXORGray04 - ICXORGray02)<=DiffThresh)          = 1;

% Case 2: Regular Gray and MaxMinSW Gray are the same
ICMask(abs(ICRegularGray - ICMaxMinSWGray)<=DiffThresh)     = 2;

% Case 3: XOR02 and MaxMinSW Gray are the same
ICMask(abs(ICXORGray02 - ICMaxMinSWGray)<=DiffThresh)       = 3;

% Case 4: XOR02 and Regular Gray are the same
ICMask(abs(ICXORGray02 - ICRegularGray)<=DiffThresh)        = 4;

% Case 5: XOR04 and MaxMinSW Gray are the same
ICMask(abs(ICXORGray04 - ICMaxMinSWGray)<=DiffThresh)       = 5;

% Case 6: XOR04 and Regular Gray are the same
ICMask(abs(ICXORGray04 - ICRegularGray)<=DiffThresh)        = 6;

% Case 7: All are the same
ICMask(abs(ICRegularGray - ICMaxMinSWGray)<=DiffThresh & abs(ICRegularGray - ICXORGray04)<=DiffThresh & abs(ICRegularGray - ICXORGray02)<=DiffThresh & abs(ICMaxMinSWGray - ICXORGray04)<=DiffThresh & abs(ICMaxMinSWGray - ICXORGray02)<=DiffThresh & abs(ICXORGray04 - ICXORGray02)<=DiffThresh) = 7;



%%% Assigning the IC values according to the cases. If any two are the
%%% same, use that value. If no two are the same, flag as error pixels. See
%%% paper for details.
%%% ��������cases��IC��ֵ�������������ֵ��ͬ����ôʹ�ø�ֵ��
%%% ���û������ֵ��ͬ�����䶨��Ϊ��������

IC(ICMask==0)    = 0;             % These are error pixels
IC(ICMask==1)    = ICXORGray04(ICMask==1);
IC(ICMask==2)    = ICMaxMinSWGray(ICMask==2);
IC(ICMask==3)    = ICMaxMinSWGray(ICMask==3);
IC(ICMask==4)    = ICXORGray02(ICMask==4);
IC(ICMask==5)    = ICMaxMinSWGray(ICMask==5);
IC(ICMask==6)    = ICXORGray04(ICMask==6);
IC(ICMask==7)    = ICMaxMinSWGray(ICMask==7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%% Filling the holes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(HoleFillFlag)

    ICFilt   = medfilt2(IC, medfiltHoleFill);          % Do a median filter ��ֵ�˲�
    
    %%% Find the code the correspondence for which is the closest to the 
    %%% final value for neighboring pixels.  �ҳ����������ص�����ֵ��ӽ��Ķ�Ӧ��ϵ�Ĵ��롣
    RegGrayDiff     = abs(ICFilt - ICRegularGray);
    GodGrayDiff     = abs(ICFilt - ICMaxMinSWGray);
    XORGray04Diff   = abs(ICFilt - ICXORGray04);
    XORGray02Diff   = abs(ICFilt - ICXORGray02);
    
    DiffTmp   = cat(3,RegGrayDiff, GodGrayDiff, XORGray04Diff, XORGray02Diff);
    %%%�������ĸ���ά��ֵ�����ںϳ���ά����
    [~, I]   = min(DiffTmp, [], 3);
    %�ҵ�ÿһ����ά��������ĵ���ά���ϵ���Сֵ
        
    ICHoleFilled    = IC;
    
    %%% Only for error pixels, use the value for the pattern which is the
    %%% closest to the final value of neighborhood pixels.
    %%% ֻ��Դ������ؽ��в�����ʹ����ӽ�����ֵ��ģʽ����ֵ������
    ICHoleFilled(I==1 & ICMask==0)      = ICRegularGray(I==1 & ICMask==0);
    ICHoleFilled(I==2 & ICMask==0)      = ICMaxMinSWGray(I==2 & ICMask==0);
    ICHoleFilled(I==3 & ICMask==0)      = ICXORGray04(I==3 & ICMask==0);
    ICHoleFilled(I==4 & ICMask==0)      = ICXORGray02(I==4 & ICMask==0);
    
    IC  = ICHoleFilled;
end