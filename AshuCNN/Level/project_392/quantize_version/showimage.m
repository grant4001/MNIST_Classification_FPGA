function show = showimage(img)
sz = size(img);
for k = 1 : sz(3)
    
subplot(8,8,k);
imshow(img(:,:,k),[0,1]);

end