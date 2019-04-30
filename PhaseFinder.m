% Load in the image
picture=imread('im5.tiff');

% Do a 2D FFT of the image
Y = fft2(picture);
% Display the FFT. Need to shift the fft, get real values, and then log it
% to exaggerate our picture.
figure(1);
imagesc(log(abs(fftshift(Y))));

% Crop out the circle we want!
% And create crops for the smudges we want to delete!
% This is a mask for our image
frtCirc = drawcircle();
smudgeCirc = drawcircle();
smudgeCirc2 = drawcircle();

yMask = createMask(frtCirc);

% Create masks to get rid of artefacts
smudgeMask = createMask(smudgeCirc);
smudgeMask2 = createMask(smudgeCirc2);

% Update mask
yMask = yMask - smudgeMask - smudgeMask2;

%532nm laser

% Create a modified version of the shifted fourier image
% This will take only the image places we want to analyze
YPrime = yMask.*(fftshift(Y));

% Shift the new image to the center
% Get center of the circle
frtCenter = round(frtCirc.Center);

% Get size of our image
[a,b,c] = size(picture);

% Find the distance to shift the masked image
dM = (a/2) - frtCenter(1,1);
dN = (b/2) - frtCenter(1,2);

% Shift the masked image!
YPShifted = circshift(YPrime, [dM, dN]);

% % Image to see where we shifted to!
% figure(394);
% imagesc(log(abs(YPShifted)));
% colormap(gray);
% colorbar;

% Get this image back to real space!
YFilt = ifft2(YPShifted);

% % Image to see if we have image again, but filtered
% figure(71);
% imagesc((log(abs(YFilt))));
% colormap(gray);
% colorbar;

% Load the background image
bckgd=imread('im5_bkgd.tiff');

% Find the 2D fourier transform
Z = fft2(bckgd);

% Display the FFT. Need to shift the fft, get real values, and then log it
% to exaggerate our picture.
% figure(2);
% imagesc(log(abs(fftshift(Z))));
% 
% % Crop out the shape we want to use!
% bckgdCirc = drawcircle();
% zMask = createMask(bckgdCirc());

% Use the cropped mask to modify our fourier image
% This allows us to work with the data we want
ZPrime = yMask.*(fftshift(Z));

% % Shift the modified image to the center
% % Get center of the circle
% bckgdCenter = round(bckgdCirc.Center);
% 
% % Get size of our image
% [aPrime,bPrime,cPrime] = size(bckgd);
% 
% % Find the distance to shift the masked image
% dMPrime = (aPrime/2) - bckgdCenter(1,1);
% dNPrime = (bPrime/2) - bckgdCenter(1,2);

% Now shift the image by the required distance
ZPShifted = circshift(ZPrime,[dM dN]);

% % Image to see where we shifted to!
% figure(419);
% imagesc(log(abs(ZPShifted)));
% colormap(gray);
% colorbar;


% Get this image back to real space!!
ZFilt = ifft2(ZPShifted);

% % Image to see if we have background again, but filtered
% figure(72);
% imagesc(log(abs(ZFilt)));
% colormap(gray);
% colorbar;

% Now take the difference of our filtered images
% This will give us the Quantitative-phase and amplitude
phase = angle(YFilt) - angle(ZFilt);

% Image amplitude
amp = abs(YFilt) - abs(ZFilt);

pi = 3.14;
% Now unwrap the unwanted phase lines from angle!
% Hopefully the image is pretty now

Q = unwrapMainQual(phase);

% Congrats! We have done a fourier thing!
figure(3);
imagesc(amp);
colormap(gray);
colorbar;

figure(4);
imagesc(Q);
colormap(gray);
colorbar;

% Crop out two rectangles
imageResult1 = imcrop();
imageResult2 = imcrop();

% Find the average value!!
sum = 0;
[xMax, yMax, ~] = size(imageResult1);
for i = 1:xMax
    for j = 1:yMax
        sum = sum + imageResult1(i,j);
    end 
end
averageResult1 = sum/(xMax + yMax);

sum = 0;
[xMax, yMax, zMax] = size(imageResult2);
for i = 1:xMax
    for j = 1:yMax
        sum = sum + imageResult2(i,j);
    end 
end
averageResult2 = sum/(xMax + yMax);

phaseDifference = averageResult1 - averageResult2