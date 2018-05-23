
%%% This function accepts as input the directory containing the encoded 
%%% sequences using the permutated binary code. permcol is the code 
%%% permutation. 
%%% ���������ͨ������õĶ����ƴ�����б����������Ϊ���룬permcol�Ǳ���������ļ���

%%% The output is an image containing the decoded 
%%% decimal integers corresponding to the projector column that 
%%% illuminated each camera pixel. A value of zero indicates a given pixel 
%%% cannot be assigned a correspondence. The projector columns are indexed 
%%% from one. IDiff1 is a measure of reliability. A low value for a
%%% pixel in IDiff1 means that pixel can not be decoded reliably. 
%%% �����һ��ʮ������������ɵľ������Ƕ�Ӧ��ͶӰͼƬÿ�����������صĽ���ֵ��
%%% ͶӰͼƬ��1��ʼ����IDiff1��һ�������ɿ��Եı������������ֵ�ܵ�������������û�б��ɿ��Ľ��롣


function [IC, IDiff1] = bindecodePerm(dirname, indexLength, permcol, nr, nc, ColImageIndices, imSuffix)

numColImages    = numel(ColImageIndices); %�����ͼƬ����

%%%% Decoding Column Indices

IC   = zeros(nr, nc);                % This will store the column index per pixel �洢ÿ�����ص�������
IDiff1   = zeros(nr, nc);          % Measuring the difference for detecting reliability/shadows
%����̽�⵽�Ŀɿ���/��Ӱֵ�Ĳ��

for i=1:numel(ColImageIndices) %�ӵ�һ��ѭ�������һ��ͶӰͼƬ
    
    I1          = double(imread([dirname, '\', sprintf(['%0', num2str(indexLength), 'd'],  ColImageIndices(i)), imSuffix]));
    I2          = double(imread([dirname, '\', sprintf(['%0', num2str(indexLength), 'd'],  ColImageIndices(i)+1), imSuffix]));        %%% Assuming the inverse image is the next one
    I1          = mean(I1,3); %����άRGB�����ɶ�ά����
    I2          = mean(I2,3);
    
    Itmp        = I1 > I2;        % Find out if the pixel is on �ж�ÿһ�����ص��Ƿ�lit on.

    IC          = IC + Itmp * 2^(numColImages-i); %��ÿ�����ص�Ӷ�������ת��Ϊʮ������
    
    IDiff1      = IDiff1 + abs(I1 - I2) ./ (I1 + I2 + eps); %����L1��L2֮���IDiff1
    
        
    ItmpL       = 255*uint8(Itmp);%ת����uint8��ʽ���д洢
    imwrite(ItmpL, [dirname, '\BitPlane', sprintf(['%02d'],  i), '.bmp']);     %%%% Saving the bitplanes �洢λͼ
    
    clear I1 I2 Itmp 
    
end

IC     = IC + 1;      % Indices start from 1 ���д�1��ʼ����  �����0��ʼ ���Լ�1
[~, IC]     = ismember(IC, permcol);      
% Using the permutation to get the indices  ͨ��permcol�ļ����IC�������е�����
IC      = IC - 1/2;       
% Get the pixel coordinate in the center ����������ص�����

IDiff1      = IDiff1 ./ numColImages; %IDiff1��һ������