%% Brain dot plot
% Stephen Zhang
% 10/2/2017

%% Set parameters

% Circle sizes
maxsize = 30;
minsize = 0.1;

% Grid size (0 = small, 1 = original size)
grid_size = 0.05;

% Threshold
% [LMO, Isl, Lim1, Lim3, AP]
threshold_vec = [30, 30, 30, 30, 30];

%% Read and resize stacks
% Read stacks
LMO = stk(:,:,1);
Isl = stk(:,:,2);
Lim1 = stk(:,:,4);
Lim3 = stk(:,:,5);
Ap = stk(:,:,3);

% Resize stacks
LMO_red = double(imresize(LMO,grid_size));
Isl_red = double(imresize(Isl,grid_size));
Lim1_red = double(imresize(Lim1,grid_size));
Lim3_red = double(imresize(Lim3,grid_size));
Ap_red = double(imresize(Ap,grid_size));

% Find coordinates
[x,y] = find(LMO_red>-100);

% Find reduced image sizes
X_size = size(LMO_red,1);
Y_size = size(LMO_red,2);

% Create reduced stack
stk_red = zeros(X_size, Y_size, 5);
cir_size_order = stk_red;
stk_red(:,:,1) = LMO_red;
stk_red(:,:,2) = Isl_red;
stk_red(:,:,3) = Lim1_red;
stk_red(:,:,4) = Lim3_red;
stk_red(:,:,5) = Ap_red;

% Define circle sizes
sizemat = zeros(X_size, Y_size, 5);
for i = 1 : 5
    stk_red_vec = stk_red(:,:,i);
    stk_red_vec = stk_red_vec(:);
    sizemat(:,:,i) = max(0, stk_red(:,:,i) - threshold_vec(i))...
        /max(stk_red_vec - threshold_vec(i)) * maxsize + minsize;
end

%% Create order of plot to ensure large circles are at bottom
% Define circle order
for i = 1 : X_size
    for j = 1 : Y_size
        [~, cir_size_order(i,j,:)] = ...
            sort(squeeze(sizemat(i,j,:)), 1, 'descend');
    end
end

% Sort out circle sizes based on circle order
sizemat_sorted = zeros(size(LMO_red,1), size(LMO_red,2), 5);

for i = 1 : X_size
    for j = 1 : Y_size
        sizemat_sorted(i,j,:) = ...
            squeeze(sizemat(i,j,cir_size_order(i,j,:)));
    end
end

% Make color (4D matrix)
% LMO = red, Isl = green, Lim1 = cyan, Lim3 = magenta, Ap = blue
colormat = zeros(X_size, Y_size, 5, 3);
colormat(:,:,1,1) = 1;
colormat(:,:,2,2) = 1;
colormat(:,:,3,2) = 1;
colormat(:,:,3,3) = 1;
colormat(:,:,4,1) = 1;
colormat(:,:,4,3) = 1;
colormat(:,:,5,3) = 1;

% Sort color based on circle order
colormat_sorted = zeros(X_size, Y_size, 5, 3);

for i = 1 : X_size
    for j = 1 : Y_size
        colormat_sorted(i,j,:,:) = ...
            squeeze(colormat(i,j,cir_size_order(i,j,:),:));
    end
end

%% Make plot
% Figure size
figure('position',[50 50 1500 700])
hold on
for i = 1 : 5
    % Scatter(X, Y, Size, Color, 'filled')
    scatter(x,y,...
        reshape(squeeze(sizemat_sorted(:,:,i)),[X_size * Y_size, 1]),...
        reshape(squeeze(colormat_sorted(:,:,i,:)),[X_size * Y_size, 3]),...
        'filled');
end
hold off

% Aspect ratio
pbaspect([0.5 0.7 1])