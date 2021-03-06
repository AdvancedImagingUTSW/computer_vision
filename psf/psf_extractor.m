%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       PSF_Extractor
%
%       This program extracts the 2DPSF-Profiles
%       user selection. Maximum Position is recalibrated and for multiple
%       Profiles they are averaged. It averages as many PSF as you select
%
%
%
%       by Reto Fiolka 08 07 2006
%                      07.09.2007 added automatic FWHM measurement
%                      (via interpoaltion) in pixels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [AvPSF]=PSF_Extractor3D(V)
%%

clear all
clc
close all

dataDirectory='/project/bioinformatics/Danuser_lab/microscopeDevelopment/raw/multiplane/BeadCalibration/Beads/100nmBeads/160330/Cell5/ch3/sheared'

dataFilename='sheared_1_CAM03_000000.tif';

dataLocation=fullfile(dataDirectory,dataFilename);

imageInfo=imfinfo(dataLocation);

pixX=160;

pixZ=600/sqrt(2);

ydim=imageInfo(1).Height;

xdim=imageInfo(1).Width;

zdim=length(imageInfo);

imageVolume=zeros(zdim,ydim,xdim);

imageVolume=zeros(zdim,ydim,xdim);

for i=1:zdim;
    imageVolume(i,:,:)=double((imread(dataLocation,i)));
    %V(i,:,:)=double(imread([dataP '/deconEDFpsf160b4.tif'],i));
end
%%
%V=V(150:end-150,200:end-200,:);

%%
clear FWHMx FWHMy FWHMz X2 X
[zdim,ydim2,x2]=size(imageVolume);
A=squeeze(max(imageVolume));
layer=0;
figure('Name', ['Stack Layer' num2str(layer) ],'NumberTitle','off','units','normalized','outerposition',[0 0 1 1]);

imshow(A,[],'Border','tight');iptsetpref('ImshowAxesVisible','off');

[x,y]=getpts

x=round(x);
y=round(y);

%Yav=(y(1)+y(2))/2;

counter=(length(x));

temp=zeros(32,32);
AvPSF=zeros(32,32);

count=1;
for i=1:counter
    
    
    SubWin=A(y(i)-3:y(i)+3,x(i)-3:x(i)+3);
    [maxi Indi]=max(SubWin(:));
    [ypeak,xpeak]= ind2sub (size(SubWin),Indi);
    
    xpeak=round(x(i)-4+xpeak)
    ypeak=round(y(i)-4+ypeak)
    
    [maxi2,zpeak]=max(imageVolume(:,ypeak,xpeak));
    
    if zpeak>15 && zpeak < zdim-15 && xpeak>15 && xpeak< xdim-15 && ypeak>15 && ypeak< ydim2-15
        
        lineZ=imageVolume(zpeak-10:zpeak+10,ypeak,xpeak);
        lineX=squeeze(imageVolume(zpeak,ypeak,xpeak-10:xpeak+10));
        lineY=squeeze(imageVolume(zpeak,ypeak-10:ypeak+10,xpeak));
        
        lineZ=lineZ-min(lineZ); lineZ=lineZ/max(lineZ);
        lineX=lineX-min(lineX); lineX=lineX/max(lineX);
        lineY=lineY-min(lineY); lineY=lineY/max(lineY);
        
        param0=[1,2,10,0];
        
        [param,resnorm,residual] = lsqcurvefit(@gaussianFunc,param0,[1:21],lineZ');
        FWHMz(count)=param(2)*2.3548;
        
        %figure;plot(gaussianFunc(param,[1:21]));hold on;plot(lineZ,'r')
        [param,resnorm,residual] = lsqcurvefit(@gaussianFunc,param0,[1:21],lineX');
        FWHMx(count)=param(2)*2.3548;
        
        [param,resnorm,residual] = lsqcurvefit(@gaussianFunc,param0,[1:21],lineY);
        FWHMy(count)=param(2)*2.3548;
        
        Z(count)=zpeak;
        X(count)=xpeak;
        Y(count)=ypeak;
        %figure;plot(gaussianFunc(param,[1:21]));hold on;plot(lineZ,'r')
        count=count+1;
    end
    
end


[X2,sortind]=sort(X,'ascend');
figure;
plot(X2,FWHMz(sortind)*pixZ,'*');
hold on;
plot(X2,FWHMy(sortind)*pixX,'r*');
hold on;
plot(X2,FWHMx(sortind)*pixX,'k*')

summarizedResults=[mean(FWHMx)*pixX, std(FWHMx)*pixX;
    mean(FWHMy)*pixX, std(FWHMy)*pixX;
    mean(FWHMz)*pixZ, std(FWHMz)*pixZ]


%%
% figure;surf(AvPSF);
% %
% figure;plot(AvPSF(:,15));
% figure;plot(AvPSF(15,:));
%
% psf=AvPSF(:,15);
%
% X=[1:length(psf)];
% XI=[1:0.1:length(psf)];
% psf=interp1(X,psf,XI);
% psf2=abs((psf)/max(psf)-0.5);
% psf2=1./psf2;
%
% indmax= find(imregionalmax(psf2) == 1);        %indexes of maxima
% [peaks,sortind]= sort(psf2(indmax),2,'descend');
% FWHM=abs(indmax(sortind(1))-indmax(sortind(2)))/10
%
% psf=AvPSF(15,:);
%
% X=[1:length(psf)];
% XI=[1:0.1:length(psf)];
% psf=interp1(X,psf,XI);
% psf2=abs((psf)/max(psf)-0.5);
% psf2=1./psf2;
%
% indmax= find(imregionalmax(psf2) == 1);        %indexes of maxima
% [peaks,sortind]= sort(psf2(indmax),2,'descend');
% FWHM2=abs(indmax(sortind(1))-indmax(sortind(2)))/10





