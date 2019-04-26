
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
y_crop = roipoly;

% Create a modified version of the shifted fourier image
% This will take only the image places we want to analyze
YPrime = y_crop.*fftshift(Y);

% Shift the new image to the center
% Not actually at the center, but hey close enough
YPShifted = circshift(YPrime,[1,1]);

% Get this image back to real space!
YFilt = ifft2(YPShifted);


% Load the background image
cellBckgd=imread('imbkgd.tif');

% Find the 2D fourier transform
Z = fft2(cellBckgd);

% Display the FFT. Need to shift the fft, get real values, and then log it
% to exaggerate our picture.
figure(2);
imagesc(log(abs(fftshift(Z))));

% Crop out the shape we want to use!
% TRY TO MAKE THESE CUTS A CIRCLE
% NEED A NEW FUNCTION TO DO SO
z_crop = roipoly;

% Use the cropped mask to modify our fourier image
% This allows us to work with the data we want
ZPrime = z_crop.*fftshift(Z);

% Shift the modified image to the center
% Again, not the actual center but good enough
ZPShifted = circshift(ZPrime,[1,1]);

% Get this image back to real space!!
ZFilt = ifft2(ZPShifted);

% Now take the difference of our filtered images
% This will give us the Quantitative-phase
cellFilt = angle(YFilt) - angle(ZFilt);

figure(3);
% Now unwrap the unwanted phase lines!
% Hopefully the image is pretty now
Q = unwrap(cellFilt);

% Congrats! We have done a fourier thing!
imshow(Q);