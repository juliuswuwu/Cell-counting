%% removing background
clc;
close all;
clear all;

cellimage = imread('cell9.jpg');
[cellimage, rect] = imcrop(cellimage);
%imshow(cellimage);



for ci = 1:size(cellimage,3)
    Test(:,:,ci) = adapthisteq( cellimage(:,:,ci) );
end
figure, imshow(cellimage),,title('orignal photo');;

% separate into different RGB channel
redChannel = cellimage(:, :, 1);
greenChannel = cellimage(:, :, 2);
blueChannel = cellimage(:, :, 3);
%figure, imshow(blueChannel);

I_invert_blue = imcomplement(blueChannel);
I_invert_green = imcomplement(greenChannel);
I_invert_red = imcomplement(redChannel);

%figure, imshow(I_invert_blue);
%figure, imhist(I_invert_green);


newgreenChannel = I_invert_green< 45 | I_invert_green >= 90;
%figure, imshow(newgreenChannel);
newgreenChannel = im2uint8(newgreenChannel)*255;

%image_fillholes = imfill(newgreenChannel,'holes');
%figure, imshow(image_fillholes);

% blue channel
newblueChannel = I_invert_blue< 40 | I_invert_blue>= 70;
%figure, imshow(newblueChannel);
newblueChannel = im2uint8(newblueChannel)*255;


%red channel
newredChannel = I_invert_red< 20 | I_invert_red>= 70;
%figure, imshow(newredChannel);
newredChannel = im2uint8(newredChannel)*255;


newrgb = bitor(imcomplement(cat(3,newredChannel,newgreenChannel,newblueChannel)),cellimage);
newrgb = imfill(newrgb);
figure, imshow(newrgb);


% sep to each color group   using k-means    (no luck) 

% cform = makecform('srgb2lab');
% lab_newrgb = applycform(newrgb, cform);
% 
% ab = double(lab_newrgb(:,:,2:3));
% nrows =size(ab,1);
% ncols = size(ab,2);
% ab = reshape(ab, nrows*ncols,2);
% 
% nColors = 10;
% [cluster_idx, cluster_center] = kmeans(ab, nColors, 'distance', 'sqEuclidean','Replicates',3);
% 
% pixel_labels = reshape(cluster_idx, nrows,ncols);
% %figure, imshow(pixel_labels,[]);
% 
% segmented_images = cell(1,3);
% rgb_label = repmat(pixel_labels, [1 1 3]);
% 
% for k = 1:nColors 
%     color = newrgb;
%     color(rgb_label ~= k) = 0;
%     segmented_image{k} = color;
%     figure, imshow(segmented_image{k}), title(k); 
% end  

redChannel2 = newrgb(:, :, 1);
greenChannel2 = newrgb(:, :, 2);
blueChannel2 = newrgb(:, :, 3);

  [yRed, x] = imhist(redChannel2);
     [yGreen, x] = imhist(greenChannel2);
     [yBlue, x] = imhist(blueChannel2);
     
    %Plot them together in one plot
   %figure, plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');

    % dead cells (Blue > ?? & Red > ?? & Green > ??  ) 
    
    %figure, imshow(greenChannel2);
    %figure, imhist(blueChannel2); 
    
    newBlueChannel2 = (blueChannel2< 173);
    newRedChannel2 = (redChannel2 < 170);
    newGreenChannel2 = (greenChannel2 < 170);
    

    deadcells = (newBlueChannel2 | newRedChannel2 | newGreenChannel2);
    %figure, imshow(deadcells);
  
 % alive cells
 
redChannel2 = newrgb(:, :, 1);
greenChannel2 = newrgb(:, :, 2);
blueChannel2 = newrgb(:, :, 3);

%  figure, imshow(greenChannel2);
%   figure, imhist(greenChannel2); 

    newGreenChannel3 = (greenChannel2> 200 & greenChannel2<250);
%figure, imshow(newGreenChannel3);
  
    alivecells = newGreenChannel3; 
    %figure, imshow(alivecells);
bw3_3 = imclose(alivecells,strel('disk',1));
bw3_3 = imfill(bw3_3,'holes');
%bw3_3 = imopen(bw3_3, strel('disk',1));
figure, imshow(bw3_3),title('alive cells');
 
[L2,num2] = bwlabel(bw3_3);
blobs2 = regionprops(L2);

areas2 = cat(1,blobs2(:).Area);
indices2 = find(areas2 > 10 );
cell_blobs2 = blobs2(indices2);

 % dead cells blobs
bw3_2 = imclose(deadcells,strel('disk',1));
bw3_2 = imopen(bw3_2, strel('disk',4));
bw3_2 = imfill(bw3_2,'holes');


figure, imshow(bw3_2),title('dead cells');


[L,num] = bwlabel(bw3_2);
blobs = regionprops(L);

% Identify large blobs
areas = cat(1,blobs(:).Area);
indices = find(areas > 10);
cell_blobs = blobs(indices);

figure, imshow(cellimage),,title(['Dead cells: ', num2str(size(indices,1)),' Alive cells: ', num2str(size(indices2,1)),' All cells: ', (num2str(size(indices2,1)+ size(indices,1)))]);
for i=1:length(cell_blobs)
rectangle('Position', cell_blobs(i).BoundingBox, 'EdgeColor', 'r'); 
end
for i=1:length(cell_blobs2)
rectangle('Position', cell_blobs2(i).BoundingBox, 'EdgeColor', 'b'); 
end
