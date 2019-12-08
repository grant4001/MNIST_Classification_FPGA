function show = showimage(img)
sz = size(img);
for k = 1 : sz(3)
    
subplot(3,3,k);
imshow(img(:,:,k),[0,1]);

end