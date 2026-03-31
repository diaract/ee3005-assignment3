clear all; close all; clc;

%% Image Loading
fprintf('=== Assignment 3: Template Matching Analysis ===\n\n');

% Load image
img = imread('C:\Users\user\Desktop\Yeni klasör\ip_image.png');

% Convert to grayscale
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Image size
[M, N] = size(img);
fprintf('Image Size: %d x %d\n', M, N);

% MANUAL 7x7 TEMPLATE SELECTION (Single Click Method)
% Display image
figure('Name', 'Template Selection - Single Click');
imshow(img);
title('Click on the CENTER of a DARK granular cell (7x7 will be selected)');
hold on;

% Show dark cells with red circles for guidance
fprintf('TIP: Click on one of the DARK (granular) cells\n');

% Single click to select location
[x, y] = ginput(1);

% Calculate 7x7 template position (center the click)
template_col = round(x) - 3;  % 7x7: center is at position 4, so offset by 3
template_row = round(y) - 3;
template_size = 7;

% Boundary check (ensure template stays within image)
template_col = max(1, min(template_col, N - template_size + 1));
template_row = max(1, min(template_row, M - template_size + 1));

% Show selected region on image
rectangle('Position', [template_col, template_row, template_size, template_size], ...
          'EdgeColor', 'r', 'LineWidth', 2);
plot(x, y, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
title(sprintf('Selected 7x7 template at [%d, %d]', template_row, template_col));
pause(1.5);  % Show selection for 1.5 seconds
close;

% Extract template
template = img(template_row:template_row+template_size-1, ...
               template_col:template_col+template_size-1);

% Template size
[tm, tn] = size(template);

% Template STD check
template_std = std(double(template(:)));
fprintf('Template selected: [%d, %d], Size: %dx%d\n', ...
        template_row, template_col, tm, tn);
fprintf('Template STD: %.2f\n', template_std);

if template_std < 20
    warning('⚠️ Template STD is too low! Choose a more textured region.');
else
    fprintf('✅ Good choice! Sufficiently distinctive.\n');
end

% Visualization
figure('Name', 'Original Image and Template', 'Position', [100 100 1200 400]);
subplot(131); imshow(img); title('Blood Cells Image');
rectangle('Position', [template_col, template_row, tn, tm], ...
          'EdgeColor', 'r', 'LineWidth', 2);
subplot(132); imshow(template); title(sprintf('Selected Template (%dx%d)', tm, tn));
subplot(133); imhist(template); title('Template Histogram');

%% TASK 1: Manual Template Matching
fprintf('\n\nTASK 1: Manual Template Matching\n');

% Initialize response maps
corr_map = zeros(M-tm+1, N-tn+1);
ssd_map = zeros(M-tm+1, N-tn+1);
sad_map = zeros(M-tm+1, N-tn+1);

% Manual sliding window
fprintf('Computing response maps...\n');
for i = 1:(M-tm+1)
    for j = 1:(N-tn+1)
        % Extract window
        window = img(i:i+tm-1, j:j+tn-1);
        
        % Cross-correlation
        corr_map(i,j) = sum(sum(double(window) .* double(template)));
        
        % SSD (Sum of Squared Differences)
        ssd_map(i,j) = sum(sum((double(window) - double(template)).^2));
        
        % SAD (Sum of Absolute Differences)
        sad_map(i,j) = sum(sum(abs(double(window) - double(template))));
    end
    
    % Progress indicator
    if mod(i, 50) == 0
        fprintf('Progress: %d/%d rows\n', i, M-tm+1);
    end
end

% 3 Intermediate calculations example
fprintf('\n--- 3 INTERMEDIATE CALCULATIONS (Manual) ---\n');
positions = [1,1; min(50,M-tm), min(50,N-tn); template_row, template_col];
for k = 1:3
    i = positions(k,1); j = positions(k,2);
    window = img(i:i+tm-1, j:j+tn-1);
    
    fprintf('\n=== Position [%d, %d] ===\n', i, j);
    fprintf('Window (%dx%d):\n', tm, tn); 
    disp(double(window));
    fprintf('Template (%dx%d):\n', tm, tn); 
    disp(double(template));
    
    % Manual calculations
    corr_val = sum(sum(double(window) .* double(template)));
    ssd_val = sum(sum((double(window) - double(template)).^2));
    sad_val = sum(sum(abs(double(window) - double(template))));
    
    fprintf('Correlation = %.2f\n', corr_val);
    fprintf('SSD = %.2f\n', ssd_val);
    fprintf('SAD = %.2f\n', sad_val);
end
    
    % Manual calculations
    corr_val = sum(sum(double(window) .* double(template)));
    ssd_val = sum(sum((double(window) - double(template)).^2));
    sad_val = sum(sum(abs(double(window) - double(template))));
    
    fprintf('Correlation = %.2f\n', corr_val);
    fprintf('SSD = %.2f\n', ssd_val);
    fprintf('SAD = %.2f\n', sad_val);

% Response maps visualization
figure('Name', 'TASK 1: Response Maps', 'Position', [100 100 1400 400]);
subplot(131); imagesc(corr_map); colorbar; title('Cross-Correlation Map (higher = better)');
colormap(subplot(131), 'jet');
subplot(132); imagesc(ssd_map); colorbar; title('SSD Map (lower = better)');
colormap(subplot(132), 'hot');
subplot(133); imagesc(sad_map); colorbar; title('SAD Map (lower = better)');
colormap(subplot(133), 'hot');

% Detect locations
[max_corr, idx_corr] = max(corr_map(:));
[corr_i, corr_j] = ind2sub(size(corr_map), idx_corr);

[min_ssd, idx_ssd] = min(ssd_map(:));
[ssd_i, ssd_j] = ind2sub(size(ssd_map), idx_ssd);

[min_sad, idx_sad] = min(sad_map(:));
[sad_i, sad_j] = ind2sub(size(sad_map), idx_sad);

fprintf('\n--- DETECTION RESULTS ---\n');
fprintf('Correlation: Peak at [%d, %d], value = %.2f\n', corr_i, corr_j, max_corr);
fprintf('SSD: Minimum at [%d, %d], value = %.2f\n', ssd_i, ssd_j, min_ssd);
fprintf('SAD: Minimum at [%d, %d], value = %.2f\n', sad_i, sad_j, min_sad);

% Mark detections
figure('Name', 'TASK 1: Detected Locations', 'Position', [100 100 1400 400]);
subplot(131); imshow(img); title('Correlation Detection');
rectangle('Position', [corr_j, corr_i, tn, tm], 'EdgeColor', 'g', 'LineWidth', 2);

subplot(132); imshow(img); title('SSD Detection');
rectangle('Position', [ssd_j, ssd_i, tn, tm], 'EdgeColor', 'b', 'LineWidth', 2);

subplot(133); imshow(img); title('SAD Detection');
rectangle('Position', [sad_j, sad_i, tn, tm], 'EdgeColor', 'r', 'LineWidth', 2);

%% TASK 2: Correlation vs Convolution
fprintf('\n\nTASK 2: Correlation vs Convolution\n');

% Correlation (already computed)
correlation_result = corr_map;

% Convolution (flip template)
template_flipped = flip(flip(template, 1), 2);
convolution_map = zeros(M-tm+1, N-tn+1);

fprintf('Computing convolution map...\n');
for i = 1:(M-tm+1)
    for j = 1:(N-tn+1)
        window = img(i:i+tm-1, j:j+tn-1);
        convolution_map(i,j) = sum(sum(double(window) .* double(template_flipped)));
    end
    if mod(i, 50) == 0
        fprintf('Progress: %d/%d rows\n', i, M-tm+1);
    end
end

figure('Name', 'TASK 2: Correlation vs Convolution', 'Position', [100 100 1400 400]);
subplot(131); imagesc(correlation_result); colorbar; title('Correlation');
subplot(132); imagesc(convolution_map); colorbar; title('Convolution');
subplot(133); imagesc(abs(correlation_result - convolution_map)); colorbar; 
title('Absolute Difference');

fprintf('\nMathematical Explanation:\n');
fprintf('Correlation: R(i,j) = Σ Σ I(x,y) × T(x,y)\n');
fprintf('Convolution: R(i,j) = Σ Σ I(x,y) × T(-x,-y)\n');
fprintf('Convolution flips the template both horizontally and vertically.\n');
fprintf('\nCritical: Correlation fails for asymmetric templates when orientation matters!\n');

%% TASK 3: Normalized Cross-Correlation (NCC)
fprintf('\n\nTASK 3: Normalized Cross-Correlation\n');

% NCC implementation
ncc_map = zeros(M-tm+1, N-tn+1);
t_mean = mean(template(:));
t_std = std(double(template(:)));

fprintf('Computing NCC map...\n');
for i = 1:(M-tm+1)
    for j = 1:(N-tn+1)
        window = double(img(i:i+tm-1, j:j+tn-1));
        w_mean = mean(window(:));
        w_std = std(window(:));
        
        if w_std > 0 && t_std > 0
            ncc_map(i,j) = sum(sum((window - w_mean) .* (double(template) - t_mean))) / ...
                          (numel(template) * w_std * t_std);
        end
    end
    if mod(i, 50) == 0
        fprintf('Progress: %d/%d rows\n', i, M-tm+1);
    end
end

% Test with brightness and contrast changes
img_bright = uint8(min(double(img) + 50, 255));  % Brightness increase
img_contrast = imadjust(img, [0.3 0.7], [0 1]);  % Contrast change

% Standard correlation on modified images
fprintf('Computing correlation on modified images...\n');
corr_bright = zeros(size(corr_map));
corr_contrast = zeros(size(corr_map));

for i = 1:(M-tm+1)
    for j = 1:(N-tn+1)
        window_b = img_bright(i:i+tm-1, j:j+tn-1);
        window_c = img_contrast(i:i+tm-1, j:j+tn-1);
        
        corr_bright(i,j) = sum(sum(double(window_b) .* double(template)));
        corr_contrast(i,j) = sum(sum(double(window_c) .* double(template)));
    end
end

% NCC on modified images
fprintf('Computing NCC on modified images...\n');
ncc_bright = zeros(size(ncc_map));
ncc_contrast = zeros(size(ncc_map));

for i = 1:(M-tm+1)
    for j = 1:(N-tn+1)
        window_b = double(img_bright(i:i+tm-1, j:j+tn-1));
        window_c = double(img_contrast(i:i+tm-1, j:j+tn-1));
        
        w_mean_b = mean(window_b(:));
        w_std_b = std(window_b(:));
        w_mean_c = mean(window_c(:));
        w_std_c = std(window_c(:));
        
        if w_std_b > 0
            ncc_bright(i,j) = sum(sum((window_b - w_mean_b) .* (double(template) - t_mean))) / ...
                             (numel(template) * w_std_b * t_std);
        end
        if w_std_c > 0
            ncc_contrast(i,j) = sum(sum((window_c - w_mean_c) .* (double(template) - t_mean))) / ...
                               (numel(template) * w_std_c * t_std);
        end
    end
end

figure('Name', 'TASK 3: NCC vs Standard Correlation', 'Position', [100 100 1400 800]);
subplot(2,3,1); imagesc(corr_map); colorbar; title('Corr: Original');
subplot(2,3,2); imagesc(corr_bright); colorbar; title('Corr: Brightness+50');
subplot(2,3,3); imagesc(corr_contrast); colorbar; title('Corr: Contrast Adj');
subplot(2,3,4); imagesc(ncc_map); colorbar; title('NCC: Original');
subplot(2,3,5); imagesc(ncc_bright); colorbar; title('NCC: Brightness+50');
subplot(2,3,6); imagesc(ncc_contrast); colorbar; title('NCC: Contrast Adj');

fprintf('\nNCC removes mean and normalizes by std deviation.\n');
fprintf('This makes it invariant to linear brightness/contrast changes!\n');

% Compare peak locations
[~, idx_ncc_orig] = max(ncc_map(:));
[~, idx_ncc_bright] = max(ncc_bright(:));
[~, idx_ncc_contrast] = max(ncc_contrast(:));

fprintf('NCC peak remains at same location despite brightness/contrast changes: ');
if idx_ncc_orig == idx_ncc_bright && idx_ncc_orig == idx_ncc_contrast
    fprintf('✅ CONFIRMED!\n');
else
    fprintf('⚠️ Some variation exists\n');
end

%% TASK 4: Standard Deviation Analysis
fprintf('\n\nTASK 4: Standard Deviation Analysis\n');

% Good match region (actual template location)
good_region = double(img(template_row:template_row+tm-1, ...
                         template_col:template_col+tn-1));

% Bad match region (find a uniform gray area)
bad_row = min(200, M-tm);
bad_col = min(200, N-tn);
bad_region = double(img(bad_row:bad_row+tm-1, bad_col:bad_col+tn-1));

% Compute statistics
fprintf('\n--- GOOD MATCH REGION (Template Location) ---\n');
good_mean = mean(good_region(:));
good_var = var(good_region(:));
good_std = std(good_region(:));
fprintf('Mean: %.2f, Variance: %.2f, Std Dev: %.2f\n', good_mean, good_var, good_std);

fprintf('\n--- BAD MATCH REGION (Different Location) ---\n');
bad_mean = mean(bad_region(:));
bad_var = var(bad_region(:));
bad_std = std(bad_region(:));
fprintf('Mean: %.2f, Variance: %.2f, Std Dev: %.2f\n', bad_mean, bad_var, bad_std);

fprintf('\n--- TEMPLATE STATISTICS ---\n');
template_mean = mean(double(template(:)));
template_var = var(double(template(:)));
template_std_val = std(double(template(:)));
fprintf('Mean: %.2f, Variance: %.2f, Std Dev: %.2f\n', template_mean, template_var, template_std_val);

fprintf('\n*** CRITICAL INSIGHT ***\n');
fprintf('Low std dev means UNIFORM region → LESS discriminative → HARDER to match uniquely.\n');
fprintf('High std dev means TEXTURED region → MORE unique features → EASIER to match!\n');
fprintf('Template with MODERATE-to-HIGH std dev gives BEST matching reliability.\n');

% Visualization
figure('Name', 'TASK 4: Standard Deviation Analysis', 'Position', [100 100 1200 400]);
subplot(131); imshow(uint8(good_region)); 
title(sprintf('Good Match\nSTD=%.2f', good_std));
subplot(132); imshow(uint8(bad_region)); 
title(sprintf('Bad Match\nSTD=%.2f', bad_std));
subplot(133); imshow(template); 
title(sprintf('Template\nSTD=%.2f', template_std_val));

%% TASK 5: Failure Case Design
fprintf('\n\nTASK 5: Failure Case Analysis\n');

% Test 1: Rotation
fprintf('Testing rotation failure...\n');
img_rotated = imrotate(img, 30, 'bilinear', 'crop');
ncc_rotated = zeros(M-tm+1, N-tn+1);

for i = 1:(M-tm+1)
    for j = 1:(N-tn+1)
        window = double(img_rotated(i:i+tm-1, j:j+tn-1));
        w_mean = mean(window(:));
        w_std = std(window(:));
        
        if w_std > 0
            ncc_rotated(i,j) = sum(sum((window - w_mean) .* (double(template) - t_mean))) / ...
                              (numel(template) * w_std * t_std);
        end
    end
end

% Test 2: Scale change
fprintf('Testing scale failure...\n');
img_scaled = imresize(img, 1.5);
img_scaled = imresize(img_scaled, [M, N]);

% Test 3: Noise
fprintf('Testing noise failure...\n');
img_noisy = imnoise(img, 'gaussian', 0, 0.01);

% Test 4: Occlusion
fprintf('Testing occlusion failure...\n');
img_occluded = img;
occlude_size = round(tm/2);
img_occluded(template_row:template_row+occlude_size-1, ...
             template_col:template_col+occlude_size-1) = 0;

figure('Name', 'TASK 5: Failure Cases', 'Position', [100 100 1400 800]);
subplot(2,3,1); imshow(img); title('Original');
subplot(2,3,2); imshow(img_rotated); title('Rotated 30°');
subplot(2,3,3); imshow(img_scaled); title('Scaled 1.5x then resized');
subplot(2,3,4); imshow(img_noisy); title('Gaussian Noise');
subplot(2,3,5); imshow(img_occluded); title('Occluded (50%)');
subplot(2,3,6); imagesc(ncc_rotated); colorbar; title('NCC on Rotated (FAILS)');

fprintf('\n*** FAILURE ANALYSIS ***\n');
fprintf('1. ROTATION: Template is orientation-specific. No rotation invariance.\n');
fprintf('   Mathematical: T(x,y) ≠ T(x·cos(θ)-y·sin(θ), x·sin(θ)+y·cos(θ))\n');
fprintf('   Solution: Use rotation-invariant features (SIFT, SURF, ORB)\n\n');

fprintf('2. SCALE: Template has fixed size. Cannot match scaled versions.\n');
fprintf('   Solution: Multi-scale pyramid matching or scale-invariant features\n\n');

fprintf('3. NOISE: Reduces correlation values, creates false peaks.\n');
fprintf('   Solution: Preprocessing (Gaussian filtering) or robust metrics\n\n');

fprintf('4. OCCLUSION: Partial match fails completely.\n');
fprintf('   Solution: Part-based models or keypoint matching\n');

%% TASK 6: Multiple Match Problem
fprintf('\n\nTASK 6: Multiple Match Problem\n');

% METHOD 1: Original template, lower threshold
fprintf('\n--- Method 1: Lower threshold with original template ---\n');
ncc_multi = ncc_map;
threshold1 = 0.60;
[peak_rows1, peak_cols1] = find(ncc_multi > threshold1);

min_distance1 = round(max(tm, tn) * 0.5);
peaks1 = [peak_rows1, peak_cols1, ncc_multi(sub2ind(size(ncc_multi), peak_rows1, peak_cols1))];
[~, sort_idx1] = sort(peaks1(:,3), 'descend');
peaks1 = peaks1(sort_idx1, :);

valid_peaks1 = [];
for k = 1:size(peaks1, 1)
    is_valid = true;
    for m = 1:size(valid_peaks1, 1)
        dist = sqrt((peaks1(k,1)-valid_peaks1(m,1))^2 + (peaks1(k,2)-valid_peaks1(m,2))^2);
        if dist < min_distance1
            is_valid = false;
            break;
        end
    end
    if is_valid
        valid_peaks1 = [valid_peaks1; peaks1(k,:)];
    end
    if size(valid_peaks1, 1) >= 6
        break;
    end
end

fprintf('Method 1 found: %d matches (threshold=%.2f)\n', size(valid_peaks1,1), threshold1);

% METHOD 2: Smaller template (if Method 1 finds < 3 matches)
if size(valid_peaks1, 1) < 3
    fprintf('\n--- Method 2: Using smaller template for more matches ---\n');
    
    small_size = 15;
    small_template = img(template_row:template_row+small_size-1, ...
                         template_col:template_col+small_size-1);
    [stm, stn] = size(small_template);
    st_mean = mean(small_template(:));
    st_std = std(double(small_template(:)));
    
    ncc_small = zeros(M-stm+1, N-stn+1);
    fprintf('Computing NCC with smaller template...\n');
    for i = 1:(M-stm+1)
        for j = 1:(N-stn+1)
            window = double(img(i:i+stm-1, j:j+stn-1));
            w_mean = mean(window(:));
            w_std = std(window(:));
            
            if w_std > 0 && st_std > 0
                ncc_small(i,j) = sum(sum((window - w_mean) .* (double(small_template) - st_mean))) / ...
                                (numel(small_template) * w_std * st_std);
            end
        end
        if mod(i, 50) == 0
            fprintf('Progress: %d/%d\n', i, M-stm+1);
        end
    end
    
    threshold2 = 0.55;
    [peak_rows2, peak_cols2] = find(ncc_small > threshold2);
    peaks2 = [peak_rows2, peak_cols2, ncc_small(sub2ind(size(ncc_small), peak_rows2, peak_cols2))];
    [~, sort_idx2] = sort(peaks2(:,3), 'descend');
    peaks2 = peaks2(sort_idx2, :);
    
    min_distance2 = round(small_size * 0.8);
    valid_peaks2 = [];
    for k = 1:size(peaks2, 1)
        is_valid = true;
        for m = 1:size(valid_peaks2, 1)
            dist = sqrt((peaks2(k,1)-valid_peaks2(m,1))^2 + (peaks2(k,2)-valid_peaks2(m,2))^2);
            if dist < min_distance2
                is_valid = false;
                break;
            end
        end
        if is_valid
            valid_peaks2 = [valid_peaks2; peaks2(k,:)];
        end
        if size(valid_peaks2, 1) >= 8
            break;
        end
    end
    
    fprintf('Method 2 found: %d matches (threshold=%.2f)\n', size(valid_peaks2,1), threshold2);
    
    % Use Method 2
    final_peaks = valid_peaks2;
    final_ncc = ncc_small;
    final_threshold = threshold2;
    final_tm = stm;
    final_tn = stn;
    method_used = 2;
else
    % Use Method 1
    final_peaks = valid_peaks1;
    final_ncc = ncc_multi;
    final_threshold = threshold1;
    final_tm = tm;
    final_tn = tn;
    method_used = 1;
end

fprintf('\n=== FINAL RESULT: %d matches using Method %d ===\n', size(final_peaks,1), method_used);

% Visualization
figure('Name', 'TASK 6: Multiple Matches', 'Position', [100 100 1400 500]);

subplot(141); imshow(img); title('Original Image');

subplot(142); imagesc(final_ncc); colorbar; title('NCC Response Map');
colormap(subplot(142), 'jet'); clim([0 1]);
hold on;
contour(final_ncc, [final_threshold final_threshold], 'r--', 'LineWidth', 2);
text(10, 30, sprintf('Threshold=%.2f', final_threshold), 'Color', 'w', ...
     'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'k');
hold off;

subplot(143); imshow(img); 
title(sprintf('%d Multiple Matches Found', size(final_peaks,1)));
hold on;
for k = 1:size(final_peaks, 1)
    if k == 1
        color = [1 0 0]; % Best match red
        lw = 3;
    else
        color = [0 1 0]; % Others green
        lw = 2;
    end
    rectangle('Position', [final_peaks(k,2), final_peaks(k,1), final_tn, final_tm], ...
              'EdgeColor', color, 'LineWidth', lw);
    text(final_peaks(k,2), final_peaks(k,1)-3, ...
         sprintf('#%d: %.2f', k, final_peaks(k,3)), ...
         'Color', 'yellow', 'FontSize', 9, 'FontWeight', 'bold', ...
         'BackgroundColor', 'black');
end
hold off;

subplot(144);
bar(1:size(final_peaks,1), final_peaks(:,3), 'FaceColor', [0.2 0.6 0.8]);
xlabel('Match Number'); ylabel('NCC Score');
title('NCC Scores for All Matches');
grid on; ylim([0 1]);
hold on;
plot([0 size(final_peaks,1)+1], [final_threshold final_threshold], 'r--', 'LineWidth', 2);
legend('NCC Scores', 'Threshold', 'Location', 'southeast');
hold off;

fprintf('\n*** MULTIPLE MATCH PROBLEM - DETAILED ANALYSIS ***\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('OBSERVATION: Template matches %d different locations!\n', size(final_peaks,1));
fprintf('AMBIGUITY QUESTION: Which match is the "true" one?\n');
fprintf('ANSWER: All %d matches are valid - they represent similar cells.\n\n', size(final_peaks,1));

fprintf('DETAILED NCC SCORES:\n');
fprintf('%-10s %-15s %-12s %-12s\n', 'Match #', 'NCC Score', 'Row', 'Col');
fprintf('%-10s %-15s %-12s %-12s\n', '-------', '---------', '---', '---');
for k = 1:size(final_peaks,1)
    fprintf('%-10d %-15.4f %-12d %-12d\n', ...
            k, final_peaks(k,3), final_peaks(k,1), final_peaks(k,2));
end



%% TASK 7: Performance Comparison
fprintf('\n\n');
fprintf('========================================\n');
fprintf('TASK 7: Performance Comparison Table\n');
fprintf('========================================\n\n');

fprintf('%-15s %-15s %-25s %-30s\n', 'Method', 'Accuracy', 'Noise Robustness', 'Brightness Sensitivity');
fprintf('%-15s %-15s %-25s %-30s\n', '------', '--------', '----------------', '-----------------------');
fprintf('%-15s %-15s %-25s %-30s\n', 'SSD', 'High', 'Low (very sensitive)', 'Very High (fails)');
fprintf('%-15s %-15s %-25s %-30s\n', 'SAD', 'High', 'Low-Medium', 'High (fails)');
fprintf('%-15s %-15s %-25s %-30s\n', 'Correlation', 'Medium-High', 'Medium', 'High (affected)');
fprintf('%-15s %-15s %-25s %-30s\n', 'NCC', 'High', 'High (best)', 'Invariant (unaffected)');
fprintf('\n');

