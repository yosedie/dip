clear; clc; close all;

% Membaca gambar
img = imread('h2.jpg');

% Mengubah gambar menjadi skala abu-abu
img_gray = rgb2gray(img);

% Mengatur ambang batas berdasarkan intensitas untuk mengidentifikasi kaos kaki putih
threshold_value_white = 100; % nilai contoh, sesuaikan jika diperlukan
binary_image_white = img_gray > threshold_value_white;

% Mengatur ambang batas berdasarkan intensitas untuk mengidentifikasi kaos kaki hitam
threshold_value_black = 50; % nilai contoh, sesuaikan jika diperlukan
binary_image_black = img_gray < threshold_value_black;

% Melakukan pembukaan morfologi untuk menghapus objek kecil
se = strel('disk', 15); % Anda mungkin perlu menyesuaikan ukuran elemen struktur tergantung pada gambar Anda
clean_image_white = imopen(binary_image_white, se);
clean_image_black = imopen(binary_image_black, se);

% Membuat elemen struktur dalam bentuk 'L'
se_L = strel('line', 15, 90); % Anda mungkin perlu menyesuaikan ukuran dan orientasi elemen struktur tergantung pada gambar Anda

% Melakukan operasi morfologi untuk mencari bentuk yang menyerupai 'L'
L_image_white = imdilate(clean_image_white, se_L);
L_image_black = imdilate(clean_image_black, se_L);

% Memberi label komponen yang terhubung dalam gambar
labeled_image_white = bwlabel(L_image_white);
labeled_image_black = bwlabel(L_image_black);

% Mengukur properti daerah gambar
stats_white = regionprops(labeled_image_white, 'Area', 'BoundingBox', 'Eccentricity', 'Solidity', 'Orientation');
stats_black = regionprops(labeled_image_black, 'Area', 'BoundingBox', 'Eccentricity', 'Solidity', 'Orientation');

% Menemukan batas kaos kaki
boundaries_white = bwboundaries(labeled_image_white);
boundaries_black = bwboundaries(labeled_image_black);

% Menampilkan gambar asli dengan kaos kaki yang diidentifikasi ditandai
imshow(img);
hold on;
for k = 1:length(boundaries_white)
   boundary = boundaries_white{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
for k = 1:length(boundaries_black)
   boundary = boundaries_black{k};
   plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
end

% Memeriksa apakah ada kaos kaki dalam gambar berdasarkan bentuknya yang mirip dengan "L"
sock_count_white = 0;
sock_count_black = 0;
for i = 1:numel(stats_white)
    % Memeriksa apakah objek memiliki bentuk yang mirip dengan kaos kaki (misalnya, objek tersebut tidak terlalu memanjang)
    if stats_white(i).Eccentricity < 0.8 && stats_white(i).Area > 1000 && stats_white(i).Area < 10000 && stats_white(i).Solidity > 0.6 && abs(stats_white(i).Orientation) < 45
        sock_count_white = sock_count_white + 1;
    end
end
for i = 1:numel(stats_black)
    % Memeriksa apakah objek memiliki bentuk yang mirip dengan kaos kaki (misalnya, objek tersebut tidak terlalu memanjang)
    if stats_black(i).Eccentricity < 0.8 && stats_black(i).Area > 1000 && stats_black(i).Area < 10000 && stats_black(i).Solidity > 0.6 && abs(stats_black(i).Orientation) < 45
        sock_count_black = sock_count_black + 1;
    end
end

% Mengatur judul tampilan berdasarkan hasil if
if sock_count_white == 1 && sock_count_black == 1
    title('Ada kaos kaki putih dan kaos kaki hitam dalam gambar!');
elseif sock_count_white > 1
    title('Ada kaos kaki hitam dalam gambar!');
elseif sock_count_black > 1
    title('Ada kaos kaki putih dalam gambar!');
else
    title('Tidak ada kaos kaki dalam gambar!');
end
