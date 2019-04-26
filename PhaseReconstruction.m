%INFO: Us and Ur contain information from the two rays intersecting 
%in the michelson interferometer. n(r) then takes the intensity. 
%N(r) takes the "fourier" (not sure) and then we crop the circle 
%we care about and center it. We then take the inverse fourier 
%to collect the image information we want
%I_r = reference arm light intensity, and it should be uniform across the field of view.

%% imwf

image=imread('imwf.tif'); %1024 x 1270 matrix

%fourier transform of image to get the 3 "spots
y =imagesc (log10(abs(fftshift(fft2(image)))));


%We only want one circle and we want to center it
y_crop = roipoly;

im_f =  y_crop.*fftshift(fft2(image));

y_crop_centered=circshift(im_f,[-1,1]);

%We now take the inverse fourier transform
yimagefiltered=log10(abs(ifftshift(ifft2(y_crop_centered))));
y_final=imagesc(angle(yimagefiltered)); 

%% imbkgd (background image/noise)

bkim=imread('imbkgd.tif'); %1024 x 1270 matrix



%fourier transform of image to get the 3 "spots"
b=imagesc(log10(abs(fftshift(fft2(bkim)))));

%We only want one circle and we want to center it
b_crop=roipoly;

im_b = b_crop.*fftshift(fft2(image));
b_crop_centered=circshift(im_b,[-1,1]);

%We take the inverse fourier transform
bimagefiltered=log10(abs(ifftshift(ifft2(b_crop_centered))));


b_final=imagesc(angle(bimagefiltered));

%% imwf-imbkgd
sub_backgrnd=angle(yimagefiltered)-angle(bimagefiltered);
phaseReconst=imagesc(sub_backgrnd);

%% Lines of Code I am not sure about

% for r=length(y)
%     for i=length(y)
% Us(r)=y(r); %sample information
% Ur(r)=sqrt(I_r).*exp(-i*k*r); %reference beam ... -i referes to Forward Fourier Transform
%     end
% end
% 
% E(r)=Us(r)+Ur(r);
% n(r)=abs(E(r)).^2; %measured intensity interferogram
% N(r)=Ir+abs(Us(r)).^2 + Us(r)*Ur(r) +  complex(Us(r)*Ur(r));
% % ambiguity + sample + complex conjugate
