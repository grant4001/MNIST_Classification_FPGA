% This script writes a single MNIST testing image into a .bmp file.
% The goal is to view an MNIST image, for reference.

s_load_mnist;

OUTPUT_NAME = 'view_im.bmp';
SAMPLE_NO = 1;
IM_DIM = 30;

im = zeros(IM_DIM, IM_DIM);
for ii = 2:29
    for jj = 2:29
        im(ii, jj) = test_x(ii-1, jj-1, SAMPLE_NO);
    end
end

%im = im ./ 256;

%%%% view sample image'
imwrite(im, strcat('Outputs/', OUTPUT_NAME));
        