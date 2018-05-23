
%%% This function accepts as input the directory containing the encoded 
%%% sequences using the permutated binary code. permcol is the code 
%%% permutation. 
%%% 这个函数将通过排序好的二进制代码进行编码的序列作为输入，permcol是编码的排序文件。

%%% The output is an image containing the decoded 
%%% decimal integers corresponding to the projector column that 
%%% illuminated each camera pixel. A value of zero indicates a given pixel 
%%% cannot be assigned a correspondence. The projector columns are indexed 
%%% from one. IDiff1 is a measure of reliability. A low value for a
%%% pixel in IDiff1 means that pixel can not be decoded reliably. 
%%% 输出是一个十进制整数的组成的矩阵。它是对应于投影图片每个被照亮像素的解码值。
%%% 投影图片从1开始排序。IDiff1是一个衡量可靠性的变量。如果它的值很低则代表这个像素没有被可靠的解码。


function [IC, IDiff1] = bindecodePerm(dirname, indexLength, permcol, nr, nc, ColImageIndices, imSuffix)

numColImages    = numel(ColImageIndices); %获得总图片张数

%%%% Decoding Column Indices

IC   = zeros(nr, nc);                % This will store the column index per pixel 存储每个像素的列索引
IDiff1   = zeros(nr, nc);          % Measuring the difference for detecting reliability/shadows
%计算探测到的可靠性/阴影值的差别

for i=1:numel(ColImageIndices) %从第一张循环到最后一张投影图片
    
    I1          = double(imread([dirname, '\', sprintf(['%0', num2str(indexLength), 'd'],  ColImageIndices(i)), imSuffix]));
    I2          = double(imread([dirname, '\', sprintf(['%0', num2str(indexLength), 'd'],  ColImageIndices(i)+1), imSuffix]));        %%% Assuming the inverse image is the next one
    I1          = mean(I1,3); %将三维RGB矩阵变成二维矩阵
    I2          = mean(I2,3);
    
    Itmp        = I1 > I2;        % Find out if the pixel is on 判断每一个像素点是否被lit on.

    IC          = IC + Itmp * 2^(numColImages-i); %将每个像素点从二进制数转换为十进制数
    
    IDiff1      = IDiff1 + abs(I1 - I2) ./ (I1 + I2 + eps); %计算L1和L2之间的IDiff1
    
        
    ItmpL       = 255*uint8(Itmp);%转换成uint8格式进行存储
    imwrite(ItmpL, [dirname, '\BitPlane', sprintf(['%02d'],  i), '.bmp']);     %%%% Saving the bitplanes 存储位图
    
    clear I1 I2 Itmp 
    
end

IC     = IC + 1;      % Indices start from 1 序列从1开始计数  矩阵从0开始 所以加1
[~, IC]     = ismember(IC, permcol);      
% Using the permutation to get the indices  通过permcol文件获得IC在排序中的索引
IC      = IC - 1/2;       
% Get the pixel coordinate in the center 获得中心像素的坐标

IDiff1      = IDiff1 ./ numColImages; %IDiff1归一化处理