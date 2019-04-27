
% Load in the image
cell=imread('imwf.tif');

% Do a 2D FFT of the image
Y = fft2(cell);
% Display the FFT. Need to shift the fft, get real values, and then log it
% to exaggerate our picture.
figure(1);
imagesc(log(abs(fftshift(Y))));

% Crop out the circle we want!
% This is a mask for our image
frtCirc = drawcircle();

yMask = createMask(frtCirc);

% Create a modified version of the shifted fourier image
% This will take only the image places we want to analyze
YPrime = fftshift(fft2(cell)).*yMask;


% Shift the new image to the center
% Get center of the circle
frtCenter = round(frtCirc.Center);

% Get size of our image
[a,b,c] = size(cell);

% Find the distance to shift the masked image
dM = abs(frtCenter(1,1) - a/2);
dN = abs(frtCenter(1,2) - b/2);

% Shift the masked image!
YPShifted = circshift(YPrime, [dM dN]);

figure(69);
imshow(YPShifted);

% Get this image back to real space!
YFilt = ifft2(ifftshift(YPrime));

% Load the background image
cellBckgd=imread('imbkgd.tif');

% Find the 2D fourier transform
Z = fft2(cellBckgd);

% Display the FFT. Need to shift the fft, get real values, and then log it
% to exaggerate our picture.
figure(2);
imagesc(log(abs(fftshift(Z))));

% Crop out the shape we want to use!
bckgdCirc = drawcircle();
zMask = createMask(bckgdCirc());

% Use the cropped mask to modify our fourier image
% This allows us to work with the data we want
ZPrime = fftshift(Z).*zMask;

% Shift the modified image to the center
% Get center of the circle
bckgdCenter = round(bckgdCirc.Center);

% Get size of our image
[aPrime,bPrime,cPrime] = size(cellBckgd);

% Find the distance to shift the masked image
dMPrime = abs(bckgdCenter(1,1) - aPrime/2);
dNPrime = abs(bckgdCenter(1,2) - bPrime/2);

% Now shift the image by the required distance
ZPShifted = circshift(ZPrime,[dMPrime dNPrime]);

figure(70);
imshow(ZPShifted);

% Get this image back to real space!!
ZFilt = ifft2(ifftshift(ZPrime));

% Now take the difference of our filtered images
% This will give us the Quantitative-phase
cellFilt = angle(YFilt) - angle(ZFilt);

cellAmp = abs(YFilt) - abs(ZFilt);

% Now unwrap the unwanted phase lines!
% Hopefully the image is pretty now
Q = unwrap(cellFilt,-4);
P = unwrap(cellAmp,-4);

% Congrats! We have done a fourier thing!
figure(3);
imshow(imadjust(Q));

figure(4);

imshow(imadjust(cellAmp));