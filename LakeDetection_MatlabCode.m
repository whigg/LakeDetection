function [] = LakeDetect_1109
%  4879.151181 seconds. (Nov 17)
% no mlock, 4 year running in around 2400 seconds
% for analysis, add May data

% use minimum lake as 2 pixels

% 10 years data: Elapsed time is 10550.407258 seconds. around 3 hours

% if without co-location constrain:
% 4 year = 1479.307472 s = 24.6551 min
% year 2000 LakeReport have 421 clusters (more, but not take very much more
% time)

% done with lake detection in single image.
% could automatically detect lakes in bright ice and dark ice
% use channel 1, reflectance

% notes on Sep 18, 2011, (after 1 year of this code has done):
%
% @ Spots detection: The histogram of contrast coefficient only consider
% cloud-free pixels when forming the histogram. Because the center normal distribution
% (i.e., background ice) is very large and thin tail (i.e., lakes) on the 
% right is always tiny, "a close-to-zero threshold" won't change while 
% the number of pixels in the histogram is vary and we set a "constant" histogram bin for
% each year. ===> However, the easier way is "include all the cloudy and cloud-free
% pixels", since cloudy pixels only contribute normal distribution (i.e., background ice) and won't be
% a problem in determining threshold.
%
% @ initiate lakes(function: InitiateLake) : register lake if we could find it twice first in the 6 
% continuous days, which is cloudy or cloud-free days.
%
% @ find existing lake or count how many miss: only search the cloud-free 
% region, since the input "LabelMap" didn't include the cloud-covered area.



close all; clear all;


global LakeLookUp LakeInxS_Add1
global RegisterMap Register_Area Register_Intensity
% global O1 O2 O3  O5 O6
global Layers_refData
global CloudFreeGroup_5 CloudFreeGroup_6
global Layers_LabelMap
global DotK_core_1 DotK_outside_1
global DotK_core_3 DotK_outside_3
global ii_outside

% year_list = 2000:1:2009;
year_list = [2000, 2003, 2006, 2009]; 
% year_list = 2009; 

    Output_Dir_raw_Detect = '/home/yuli/SmallHD/LakeDetect_Other/LakeDetect_ResultFigure/AnalysisResult/SpotDetect/';
    Output_Dir_print = '/home/yuli/SmallHD/LakeDetect_Other/LakeDetect_ResultFigure/AnalysisResult/Raw/';    
    Output_Dir_temporal = '/home/yuli/SmallHD/LakeDetect_Other/LakeDetect_ResultFigure/AnalysisResult/Temporal/';
    
% %     MapNoIsland = imread('ScreenOutIsland.png', 'png');
% %     MapNoIsland(MapNoIsland == 255) = 1;
   
ii_outside = 25; % In order to have one center, this have to be odd number, 3,5,7,etc. 
% largest lake is two lakes merged on Julienne date 198, year 2009. It is
% 19-pixel long
% previous works said largest lake they found is 3kmx3km = 12x12
% so we set it double
ii_core_1 = 1;
ii_core_3 = 3;

    StructureElement(ii_core_1, ii_core_3);
    
tic
% % for RR = 1:1:2 
for RR = 1:1:2 

% % %         SaveTr    ackImg = 0; % save detected lake in temporal result
% % %         SaveOutputImg = 0; % save the detected lake in single image
% % %         MaskSource = 1; % 0: saved automatic result  1: automatic detected
% % %         ChooseChosenImg = 1; % 1: calculate best iamge for each date, 0: load previous calcualte one
% % %         Run_1or2 = 2; % first run, create raw image; second run, temporal image recording

    
    if RR == 1
        SaveTrackImg = 1; % save detected lake in temporal result
        SaveOutputImg = 1; % save the detected lake in single image
        MaskSource = 1; % 0: saved automatic result  1: automatic detected
        ChooseChosenImg = 1; % 1: calculate best iamge for each date, 0: load previous calcualte one
        Run_1or2 = 1; % first run, create raw image; second run, temporal image recording                
    else
        SaveTrackImg = 1; % save detected lake in temporal result
        SaveOutputImg = 1; % save the detected lake in single image
        MaskSource = 0; % 0: saved automatic result  1: automatic detected
        ChooseChosenImg = 0; % 1: calculate best iamge for each date, 0: load previous calcualte one
        Run_1or2 = 2; % first run, create raw image; second run, temporal image recording
    end
    
    for ii = 1:1:length(year_list)
        year = year_list(ii);
        disp(['year = ',num2str(year)]);
        
        if SaveTrackImg==1 && RR==1
            % ------ delete files -----
            delete([Output_Dir_raw_Detect,num2str(year),'*.png']);
            delete([Output_Dir_print,num2str(year),'*.png']);
            delete([Output_Dir_temporal,num2str(year),'*.png']);
            %------------
        end
        
        if SaveTrackImg == 1 && RR==2

            % %     tttt = uint8(255 .* data_noCM/0.9);
            % %     imwrite(tttt, [Output_Dir_temporal, num2str(year), num2str(DD), '__Track.png'], 'PNG');

                Filelist = DIRR([Output_Dir_print, num2str(year),'*.png']);
                N_file = size(Filelist,1);
                for jj = 1:1:N_file

                    files = imread([Output_Dir_print,Filelist(jj,1).name],'png');
                    temp = Filelist(jj,1).name;
                    qq = [temp(1:7),'__Track.png'];
                    imwrite(files,[Output_Dir_temporal, qq], 'png');
                end
        end            
        

        MOD02_Dir = ['/home/yuli/SmallHD/LakeDetect_Data_Grid_10year/MOD02_Grid/', num2str(year),'_MOD02_Grid/'];
        MOD10_L2_Dir = ['/home/yuli/SmallHD/LakeDetect_Data_Grid_10year/MOD10_L2_Grid/', num2str(year),'_MOD10_L2_Grid/'];


        LakeDetect_EachYear(year_list(ii), MOD02_Dir, MOD10_L2_Dir, ...
            Output_Dir_raw_Detect, Output_Dir_print, Output_Dir_temporal, SaveTrackImg, SaveOutputImg, ... %MapNoIsland, 
            MaskSource, ChooseChosenImg, Run_1or2);
    end

end
toc

if (mislocked('MOD10_L2_IceRockMask'))
    munlock MOD10_L2_IceRockMask 
    clear('MOD10_L2_IceRockMask')
end

if (mislocked('calculate_ChosenImg_List'))
    munlock calculate_ChosenImg_List
    clear('calculate_ChosenImg_List')
end

if (mislocked('FindRoughSeed'))
    munlock FindRoughSeed
    clear('FindRoughSeed')
end

if (mislocked('SingleImg_Lake_Seed'))
    munlock SingleImg_Lake_Seed
    clear('SingleImg_Lake_Seed')
end

if (mislocked('FindLake_SingleImage'))
    munlock FindLake_SingleImage
    clear('FindLake_SingleImage')
end

if (mislocked('LabelCluster'))
    munlock LabelCluster
    clear('LabelCluster')
end

if (mislocked('TrackLake'))
    munlock TrackLake
    clear('TrackLake')
end

if (mislocked('InitiateLake'))
    munlock InitiateLake
    clear('InitiateLake')
end

if (mislocked('IsCorrespondQ_2'))
    munlock IsCorrespondQ_2
    clear('IsCorrespondQ_2')
end

if (mislocked('IsCorrespondQ_1_2'))
    munlcok IsCorrespondQ_1_2
    clear('IsCorrespondQ_1_2')
end

if (mislocked('CalIntensity'))
    munlock CalIntensity
    clear('CalIntensity')
end

if (mislocked('LakeDetect_EachYear'))
    munlock LakeDetect_EachYear
    clear('LakeDetect_EachYear')
end
% munlock LakeDetect_1109 
% clear('LakeDetect_1109')

function [] = LakeDetect_EachYear...
    (year, MOD02_Dir, MOD10_L2_Dir, ...
    Output_Dir_raw_Detect, Output_Dir_print, Output_Dir_temporal, SaveTrackImg, SaveOutputImg, ... %MapNoIsland, 
    MaskSource, ChooseChosenImg, Run_1or2)

% mlock

global LakeLookUp LakeInxS_Add1
global RegisterMap Register_Area Register_Intensity
% global O1 O2 O3 O4 O5 O6
global Layers_refData
global CloudFreeGroup_5 CloudFreeGroup_6
global Layers_LabelMap

Img_rr = 1000;      Img_cc = 500;
ref_rad = 'ref';
ch01_ch02 = 'ch01';

KERNEL = ones(3,3); % kernel for erosion / dilation
Area_Thr = 0.3; % 0.5
Bright_Thr = 0.15; % image with average reflectance larger than 0.2 (ch2)
% >0.15 for ch1 reflectance
% has solar angle less than 75 degree

Mask_All_1= ones(Img_rr, Img_cc);

% FilledValue = 65535;
NotSignal = -0.01;

% Small_1stDeri = 1e-3;
AlmostZero_1stDeri = 1e-2; %"1e-3" is too small. tune to detect more lakes 
% AlmostZero_2ndDeri = 1e-3;

% NofMergeLake = 0;
% ZeroMap = zeros(Img_rr,Img_cc);
ZeroMap_long = zeros(Img_rr*Img_cc,1);
%% ======== MOD10_L2 : extract single mask for one summer =============
% ---- based on previous found best image for each date -----
% if use "every image", the negative part is too many (many no signal imags) 


% %         load Mask_ice_rock_2
if (MaskSource == 0) % use the manully plot one

    if year == 2000
        load CloudMask_2000_1109
    elseif (year == 2001)
        load CloudMask_2001_1109
    elseif (year == 2002)
        load CloudMask_2002_1109
    elseif (year == 2003)
        load CloudMask_2003_1109
    elseif (year == 2004)
        load CloudMask_2004_1109
    elseif (year == 2005)
        load CloudMask_2005_1109
    elseif (year == 2006)
        load CloudMask_2006_1109
    elseif (year == 2007)
        load CloudMask_2007_1109
    elseif (year == 2008)
        load CloudMask_2008_1109
    elseif (year == 2009)
        load CloudMask_2009_1109
    elseif (year == 2010)
        load CloudMask_2010_1109
    end        

else % automatically detect ice/rock mask, use previous chosen image for each date
    [Mask_ice_area, Mask_ice_rock] = MOD10_L2_IceRockMask ...
        (ZeroMap_long, MOD10_L2_Dir,Img_cc, Img_rr, KERNEL, ...
        year, Area_Thr); %, MapNoIsland); 
    
    if (year == 2000)
        save CloudMask_2000_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2001)
        save CloudMask_2001_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2002)
        save CloudMask_2002_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2003)
        save CloudMask_2003_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2004)
        save CloudMask_2004_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2005)
        save CloudMask_2005_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2006)
        save CloudMask_2006_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2007)
        save CloudMask_2007_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2008)
        save CloudMask_2008_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2009)
        save CloudMask_2009_1109 Mask_ice_area Mask_ice_rock
    elseif (year == 2010)
        save CloudMask_2010_1109 Mask_ice_area Mask_ice_rock
    end        
end

% =========================

% N_Bin = 2000; % total number of bin
N_Bin = floor(Mask_ice_area*0.9/nthroot(Mask_ice_area*0.9,3));
% for example: for 1000000 elements, get average 100 in each bin, devide in
% 10000 # of bin. for 1000 elements, get average 10 in each bin, devide in
% 100 # of bin.
%
% In here, we want to compare all images in each summer have in 
% the histogram with the same resolution. Therefore, choose one # of bin
% based on the Mask_ice_area*0.9 for each summer

N_AvePoint = floor(N_Bin/40); %101 while N_Bin = 2000;

temp = N_AvePoint/2;
if (temp == floor(temp)) %even number, but we need odd number
    N_AvePoint = N_AvePoint+1;
end
% for histogram, # of average point, odd numer,
% this have to smaller than the smallest histogram bump we want to detect

N_AvePoint_Deri = floor(N_Bin/20); %201 while N_Bin = 2000; 
temp = N_AvePoint_Deri/2;
if (temp == floor(temp)) %even number, but we need odd number
    N_AvePoint_Deri = N_AvePoint_Deri+1;
end
% For 1st derivitive, # of average point, odd number

%% ========== choose best image for each date ===============
% Use MOD10_L2 icey land as mask. It's not perfect (it get rid of cloud,
% but also lakes), but could give a roughly good estimation of image
% quality

% %   ChosenImg_TimeTag = cellstr('temp'); 
% %   Register_Area_Day = [];  only output julienne date
% % zeros(Day_end-Day_start+1,5);
% %   % year, date, ave brightness, max brightness, sza (center point)

if (ChooseChosenImg == 0)
    if (year == 2000)
        load ChosenImg_2000_1109
    elseif (year == 2001)
        load ChosenImg_2001_1109
    elseif (year == 2002)
        load ChosenImg_2002_1109
    elseif (year == 2003)
        load ChosenImg_2003_1109
    elseif (year == 2004)
        load ChosenImg_2004_1109
    elseif (year == 2005)
        load ChosenImg_2005_1109
    elseif (year == 2006)
        load ChosenImg_2006_1109
    elseif (year == 2007)
        load ChosenImg_2007_1109
    elseif (year == 2008)
        load ChosenImg_2008_1109
    elseif (year == 2009)
        load ChosenImg_2009_1109
    elseif (year == 2010)
        load ChosenImg_2010_1109
    end
    
else
    [ChosenImg_TimeTag Register_Area_Day] = ...
        calculate_ChosenImg_List ...
        (year, ref_rad, ch01_ch02, NotSignal, ...
        MOD02_Dir, MOD10_L2_Dir,Img_cc, Img_rr, ...
        Area_Thr, Bright_Thr, N_Bin, N_AvePoint, N_AvePoint_Deri, ...
        AlmostZero_1stDeri, Mask_ice_rock, Output_Dir_print, SaveTrackImg);



    if (year == 2000)
        save ChosenImg_2000_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2001)
        save ChosenImg_2001_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2002)
        save ChosenImg_2002_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2003)
        save ChosenImg_2003_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2004)
        save ChosenImg_2004_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2005)
        save ChosenImg_2005_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2006)
        save ChosenImg_2006_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2007)
        save ChosenImg_2007_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2008)
        save ChosenImg_2008_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2009)
        save ChosenImg_2009_1109 ChosenImg_TimeTag Register_Area_Day
    elseif (year == 2010)
        save ChosenImg_2010_1109 ChosenImg_TimeTag Register_Area_Day
    end
    
%    fprintf(['# of MOD02 without cloud mask (MOD10_L2) : ', ...
%        num2str( size(MOD02_without_MOD10_L2,1)/2)  ]);
    
end

if (Run_1or2 == 1)
    return; 
end


%% ============= Lake Detection for each day ===========  
% % % % % working parameters for 2009
% % % % % N_Bin = 2000; % total number of bin
% % % % %         N_AvePoint = 51; % for histogram, # of average point, odd numer,
% % % % %         % this have to smaller than the smallest histogram bump we want to detect
% % % % % 
% % % % %         N_AvePoint_Deri = 101; % For 2st derivitive, # of average point, odd number


% [N_ChosenImg, ~] = size(ChosenImg_Brightness_sza);
N_ChosenImg = length(Register_Area_Day);

RegisterMap = zeros(Img_rr*Img_cc,1); % recoard location index of last appear lake
% RegisterMap = zeros(Img_rr, Img_cc); % recoard last appear lake

Register_Area = []; 
% (1) +-1~5 or 0, (-: left missing day for unestablished lake
%    +: left missing day for establish lake, and 0: stop.)
% (2) examine day, 
% (3) last area (not Maximum Area,)
% (4) area (N_image, 1), positive area is changed one; negative area is
% unchanged lake.
% (5) last Area index (not maximum Area index) (300)
% (6) last 2: 1000+number of merge, for the lakes after merge
% (7) last one: number of merge, for lakes before merging

Register_Intensity=[]; % for each day
% (1) darkest pixel intensity (N_image,1)
% (2) top 5% dark pixel intensity (N_image,1)
% (3) average intensity of lake (N_image,1)

% Register_Area_Day = ChosenImg_Brightness_sza; % available Julienne day for each year
% Register_Area_Day = (ChosenImg_Brightness_sza(:,2)); % available Julienne day for each year
Top5PIceIntensity = zeros(length(Register_Area_Day), 1); % Top 5 percent ice intensity, use this to estimate the gray or dark spots.

LakeReport = []; % 1(maximum Area) + Area + 300, the maximum location
IntensityReport = []; % (1) darkest pixel intensity (N_image,1)
% (2) top 5% dark pixel intensity (N_image,1)
% (3) average intensity of lake (N_image,1)


N_merge = 0;
TemporalW = 6; % temporal window, the temporal examining day
LakeInxS = 300;
LakeInxS_Add1 = LakeInxS + 1;
LakeLookUp = zeros(LakeInxS_Add1 * 1500, TemporalW);

LakeLookUp_Zero = zeros(LakeInxS_Add1 * 1500, 1);
% use 1500 lake (with min=573, max = 1051)
% use 300 as lake index storage instead 23 * 23 = 529
% "1" is for store area

Layers_LabelMap = zeros(Img_cc*Img_rr, TemporalW);

M1 = [];    M2 = [];    M3 = [];    M4 = [];    M5 = [];
CloudFreeGroup_6 = ZeroMap_long;

% O1 = [];    O2 = [];    O3 = [];    O4 = [];    O5 = [];
Layers_refData = zeros(Img_cc*Img_rr, TemporalW);

% ======== count the difference between single image detect and
% load Report_2006_0713_submit %<----------- input
% % % T1S1_AllYear = zeros(1,N_ChosenImg);
% % % T0S1_AllYear = zeros(1,N_ChosenImg);
% % % T1S0_AllYear = zeros(1,N_ChosenImg);
% ==============================================================

for ii = 1:1:N_ChosenImg +5
    
  if ii<=N_ChosenImg
    
    DD = Register_Area_Day(ii); %ChosenImg_Brightness_sza(ii, 2);
    fprintf(['\n   (Lake Detect) year: ',num2str(year), ', Day : ',num2str(DD), '    ', num2str(ii), ' ']);
    
    
    % ---- channel 1 reflectance ----
    Current_Img = char(ChosenImg_TimeTag(ii, 2)); % MOD02 file name

% %         ch1_GridCM = strrep(Current_Img, 'ch02', 'ch01');        
% %         fid = fopen([MOD02_Dir, ch1_GridCM], 'rb');
    fid = fopen([MOD02_Dir, Current_Img], 'rb');
    data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);    data_noCM = data';
    Mask_signal = Mask_All_1;
    Mask_signal(data_noCM > 1.0) = 0; % get rid of filled value from soruce data (3.3) and grided algorithm(65535).
    data_noCM(data_noCM >1.0) = NotSignal;        

%     figure(1); imshow(data_noCM, [0, 1 ], 'InitialMagnification', 67);
% figure(400); subplot(1,5,1); imshow(data_noCM, [0,1], 'InitialMagnification', 67);

    % ----- extract cloud mask from MOD10_L2-----
    Current_Img = char(ChosenImg_TimeTag(ii, 3)); % MOD10_L2 file name   

    % Have tried the "snqa" files, but no "land" (snqa == 225) information there.
    % Also tried the 'no snow' option in "snow" (snow == 25), land is 'no
    % snow', but large lakes is also included in 'no snow' pixels
    % choose not to use it eventually.
       
    fid = fopen([MOD10_L2_Dir, Current_Img], 'rb');
    data = fread(fid, [Img_cc, Img_rr], 'uint8');  fclose(fid);
    data_snow = data';
%     figure(2); imshow(data_snow, [0, 255 ]);

% ------ eliminate the small grants in the cloud Mask -------
    Mask = uint8(data_snow == 50); % 50: cloud mask
%     figure(2); imshow((data_snow == 50), [0, 1]);


    % 2 erosion is enough for getting rid of noise of the normal size of lake
    for jj = 1:1:2 %erosion of foreground (white) % get rid of lake mistake with cloud        
        Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
        Mask = (Mask_temp == 9);
    end
    for jj = 1:1:5 %Dilate foreground % get rid of small holes of cloud
        Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
        Mask = (Mask_temp > 0);
    end
    for jj = 1:1:4 %erosion % get it back
        Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
        Mask = (Mask_temp == 9);
    end
    
%     figure(3); imshow(Mask, [0, 1]);

    % -------------------
%     Mask = uint8((Mask_signal==1) & (Mask_ice_rock==1) & (Mask==0)); 
    Mask = Mask_signal .* Mask_ice_rock .* (Mask==0); 
    % Mask eliminate bad signals, cloud, & rock
    
    
    % --------- Find Lake seed by automatic thresholding in 
    % non-normalized histogram of difference kernel. Result could
    % detect most of the lakes ------------
    [inx_possibleLake, message, TopBright5P] = SingleImg_Lake_Seed ...
        (data_noCM, Mask, N_Bin, N_AvePoint, N_AvePoint_Deri, ...
        AlmostZero_1stDeri);

%     inx_possibleLake = inx_possibleLake_core_1;
%     LakesAndRawData(data_noCM, Mask, inx_possibleLake, NotSignal)
    Top5PIceIntensity(ii) = TopBright5P;

    % ----- output the easy to see figures -----------    
if (SaveOutputImg == 1)
% % %     tttt = uint8(255 .* data_noCM./0.9); % /0.9 is to linear expand the brightness
% % %     imwrite(tttt, [Output_Dir_print, num2str(year), num2str(DD), '.png'], 'PNG');
% % % %     imwrite(tttt, [Output_Dir_raw_Detect, num2str(year), num2str(DD), '_',message,'_O.png'], 'PNG');
% % %     tttt = uint8(single(tttt).* Mask);
% % %     imwrite(tttt, ['C:\Users\yuli\Desktop\PNGimage\', num2str(DD), '_CM_withRock.png'], 'PNG');

    % detected lakes
% % % % %     Maxtt1 = 0.9;
% % % % %     tt1 = data_noCM/Maxtt1;
% % % % %     temp = zeros([size(tt1),3]);
% % % % % 
% % % % %     tt2 = tt1;
% % % % %     tt2(inx_possibleLake) = Maxtt1; % previous: red
% % % % %     temp(:,:,1) = tt2;
% % % % % 
% % % % %     tt2 = tt1;
% % % % %     tt2(inx_possibleLake) = 0;    
% % % % %     temp(:,:,2) = tt2;
% % % % %     temp(:,:,3) = tt2;
% % % % %     
% % % % % %     temp = uint8(temp); % this is for the 0~255 images
% % % % % %     figure(201); %subplot(1,2,2); 
% % % % %     
% % % % %     imwrite(temp, [Output_Dir_raw_Detect, num2str(year), num2str(DD), '_',messa/ge,'_DL_1.png'], 'PNG');
    
end
    

    % whne no lake found, skip it and to the next date.
    if (isempty(inx_possibleLake))
%         fprintf('\n No lakes found: could be (1) Symetric historgram: end
%         of summer or a homogeneous cloudy day. (2) not much enought distinguish points');
        continue;
    end

    % --------- lake detection (single image) ------------------            
    [LabelMap, LakeLookUp_temp] = ...
        FindLake_SingleImage(Mask, inx_possibleLake, LakeInxS_Add1, Img_rr, Img_cc);
    % LabelMap: map with spots with labeled numbers. no spots area are
    % labeled as zeros

%      LakesAndRawData(data_noCM, Mask, find(LabelMap>0), NotSignal)


if (SaveOutputImg == 1)    
    Inx = (LabelMap > 0);        
    % detected lakes
    Maxtt1 = 0.9;    
    tt1 = data_noCM./Maxtt1; % /Maxtt1 is for linearly expand brightness
    tt1(Inx) = 1; %Maxtt1; % current: white; previous: red
    imwrite(tt1, [Output_Dir_raw_Detect, num2str(year), num2str(DD), '_',message,'_DL_2.png'], 'PNG');

    
    
% % %         tt1 = data_noCM/Maxtt1;
% % %     temp = zeros([size(tt1),3]);
% % % 
% % %     tt2 = tt1;
% % %     tt2(Inx) = Maxtt1; % previous: red
% % %     temp(:,:,1) = tt2;
% % % 
% % %     tt2 = tt1;
% % %     tt2(Inx) = 0;    
% % %     temp(:,:,2) = tt2;
% % %     temp(:,:,3) = tt2;
% % % 
% % %     imwrite(temp, [Output_Dir_raw_Detect, num2str(year), num2str(DD), '_',message,'_DL_2.png'], 'PNG');

end


% % % % % %          Inx_pre = find(LabelMap_pre > 0);
% % % % %         PlotLakes(Inx, Inx, data_noCM, 1, NotSignal) %% plot the found lakes
% % % % %         title(['red: Day ', num2str(DD), ', blue: Day ', num2str(DD_pre)]);


% % % %     % ============== count the difference between single image detect and
% % % %     % temporal tracking: +: in singal, but not show in temporal reuslt
% % % %     % - : another way around ================
% % % %     
% % % %     T1S1 = 0; % number of lake both in temporal reuslt and single image
% % % %     T1S0 = 0; % # of lake, in temporal result but not single image (cloud)
% % % %     T0S1 = 0; % # of lake, not in temporal result but in single image (noise, small dots, or lakes which don't have continuous frame)
% % % %     
% % % %     Inx_AppearLake = find(LakeReport(:,1)<= DD & LakeReport(:,2) >= DD); % include all the recorded lakes
% % % %         TempMap = zeros(1000,Img_cc);
% % % %         for zz = 1:1:length(Inx_AppearLake) % each cluster in Temporal Tracking result           
% % % %             Inx = Inx_AppearLake(zz);
% % % %             LakePixel = LakeReport(Inx, 5:4+LakeReport(Inx,4) );
% % % %             TempMap(LakePixel) = 1;
% % % %             
% % % %             if (any(LabelMap(LakePixel) >0)) % Temporal Tracking=1, and signal image detection =1, T1S1
% % % %                 T1S1 = T1S1 + 1;
% % % %             else % (~any(LabelMap(LakePixel) >0)) % Temporal Tracking=1, and signal image detection =0, T1S0
% % % %                 T1S0 = T1S0 + 1;
% % % %             end
% % % %         end
% % % %         
% % % %         Yuli_cluster = max(max(LabelMap));
% % % %     
% % % %         % cluster in single image detection result: S1
% % % %     for qq = 1:1:Yuli_cluster
% % % %         Inx_Cluster_ii = find(LabelMap==qq);
% % % %     
% % % %         if (~any(TempMap(Inx_Cluster_ii) == 1)) % have no overlap with temporal result, T0S1
% % % %             T0S1 = T0S1 + 1;
% % % %         end
% % % %     end
% % % % 
% % % %     T1S1_AllYear(ii) = T1S1;
% % % %     T1S0_AllYear(ii) = T1S0;
% % % %     T0S1_AllYear(ii) = T0S1;
% % % % continue;

% ===================================================================


    % in "FindLake_SingleImage", the lake overlapped with cloud mask have been removed
  end
  
        if ii<=N_ChosenImg 
            Layers_LabelMap(:,TemporalW) = reshape(LabelMap, [],1); %L6           
            M6 = reshape(Mask, [],1);
            DayInx1to6(6) = ii;
            
            Layers_refData(:,TemporalW) = reshape(data_noCM, [],1); % O6
%             O6 = reshape(data_noCM, [],1);
            
            temp = reshape(LakeLookUp_temp, [],1);
            ll = length(temp);
            LakeLookUp(1:ll,TemporalW) = temp;
        else
            Layers_LabelMap(:,TemporalW) = ZeroMap_long; %L6
            M6 = reshape(Mask_ice_rock, [],1);
            DayInx1to6(6) = ii;
            
            Layers_refData(:,TemporalW) = ZeroMap_long; %O6
%             O6 = ZeroMap_long;
            
            LakeLookUp(:,TemporalW) = LakeLookUp_Zero;
        end
                
%         Layers_LabelMap(:,TemporalW) = L6;
        CloudFreeGroup_6 = CloudFreeGroup_6 + M6;
        
        if ~isempty(M1)
            CloudFreeGroup_5 = CloudFreeGroup_6 - M1;
        else
            CloudFreeGroup_5 = CloudFreeGroup_6;
        end
        
%         CloudFreeGroup_5 = M2+M3+M4+M5+M6;
%         CloudFreeGroup_6 = M1+CloudFreeGroup_5;

    % ----- Registering & output report ------
    % RegisterInfo + current
    if ~isempty(M1)
        if ( ~isempty(Register_Area)  )
            [LakeReport_temp, IntensityReport_temp, N_merge] = ...
                TrackLake(DayInx1to6, N_ChosenImg, N_merge, ...
                Register_Area_Day, SaveTrackImg, Output_Dir_temporal, year);

            LakeReport = [LakeReport, LakeReport_temp];
            IntensityReport = [IntensityReport, IntensityReport_temp];

        end
            
            InitiateLake(DayInx1to6, N_ChosenImg)
    end

        M1 = M2;        
%         O1 = O2;
        M2 = M3;
%         O2 = O3;
        M3 = M4;
%         O3 = O4;
        M4 = M5;
%         O4 = O5;
        M5 = M6;
%         O5 = O6;
        
        Layers_refData(:,1:TemporalW-1) = Layers_refData(:,2:TemporalW);
        DayInx1to6(1:TemporalW-1) = DayInx1to6(2:TemporalW);
        LakeLookUp(:,1:TemporalW-1) = LakeLookUp(:,2:TemporalW);
        Layers_LabelMap(:,1:TemporalW-1) = Layers_LabelMap(:,2:TemporalW);
        
    
        if ~isempty(M1)
            CloudFreeGroup_6 = CloudFreeGroup_5;
        end
    
    % ============== count the difference between single image detect and
% % % %     % temporal tracking: +: in singal, but not show in temporal reuslt
% % % %     % - : another way around ================
% % % %         
% % % %     N_All_Track = size(Register_Area,2);
% % % %     N_All_Spot = max(max(L1));
% % % % 
% % % %     if N_All_Track~=0 && N_All_Spot ~=0
% % % %     
% % % % % % %     T1S1 = 0; % number of lake both in temporal reuslt and single image
% % % % % % %     T1S0 = 0; % # of lake, in temporal result but not single image (cloud)
% % % % % % %     T0S1 = 0; % # of lake, not in temporal result but in single image (noise, small dots, or lakes which don't have continuous frame)
% % % % 
% % % %     
% % % %     temp = (L1>0 & RegisterMap>0);
% % % %     
% % % %     Inx_Track = sort(RegisterMap(temp), 'ascend');    
% % % %     N_Track = 1;
% % % %     for ww = 2:1:length(Inx_Track)
% % % %         if Inx_Track(ww) ~= Inx_Track(ww-1);
% % % %             N_Track = N_Track + 1;
% % % %         end
% % % %     end
% % % %     
% % % %     Inx_Spot  = sort(L1(temp), 'ascend');
% % % %     N_Spot = 1;
% % % %     for ww = 2:1:length(Inx_Spot)
% % % %         if Inx_Spot(ww) ~= Inx_Spot(ww-1);
% % % %             N_Spot = N_Spot + 1;
% % % %         end
% % % %     end
% % % %     
% % % %     T1S1_AllYear(ii-5) = N_Track; %T1S1;
% % % %     T1S0_AllYear(ii-5) = N_All_Track - N_Track; %T1S0;
% % % %     T0S1_AllYear(ii-5) = N_All_Spot - N_Spot; %T0S1;
% % % %     
% % % %     end
    % ====================
    

end


% % % %     if (year == 2000)
% % % % save T10S10_0809_2000 T1S1_AllYear T1S0_AllYear T0S1_AllYear
% % % %     elseif (year == 2003)
% % % % save T10S10_0809_2003 T1S1_AllYear T1S0_AllYear T0S1_AllYear
% % % %     elseif (year == 2006)
% % % % save T10S10_0809_2006 T1S1_AllYear T1S0_AllYear T0S1_AllYear
% % % %     elseif (year == 2009)
% % % % save T10S10_0809_2009 T1S1_AllYear T1S0_AllYear T0S1_AllYear
% % % %     end

% % % % % fprintf('look up the T1S1, T0S1, and T1S0 \n');
% % % % % keyboard;



% ============ post pocessing
% -------- label the already output one as -1 (disappear in the mid summer
% possiblely because of drainage)
% merged lake is already have zero at the end
% % % % % % % % % % % % % % % % % %     temp = (LakeReport(:,end) == 0);
% % % % % % % % % % % % % % % % % %     LakeReport(temp,end) = -1;
% % % % -------- organized merged lakes, output the number of label of merged
% % % % lake
% % % for ii= 1:1:NofMergeLake
% % %     MergeLakeInx = find(LakeReport(:,end-1) == 1000+NofMergeLake);
% % %     temp = (LakeReport(:,end) == NofMergeLake);
% % %     LakeReport(temp,end) = MergeLakeInx;
% % % end

% -------- output the "haven't output but has being established" one as -2
% (disappear by the end summer (forzen)

% % % temp = (LakeObserve(:,1) == 1); % the established lakes
% % % tt = [LakeObserve(temp,2), LakeObserve(temp,end), ...
% % %     -1.*LakeObserve(temp,4), RegisterInfo(temp, 5:end-1), ...
% % %     ones(sum(temp),1).*-2];

temp = (Register_Area(1,:) > 0); % the established lakes
% tt = [Register_Area(temp,3:3+N_ChosenImg+299), ones(sum(temp),1).*-2];
% LakeReport = [LakeReport; tt]; % mark -2 at the end
                %(4+200); % start day, last appear day before end day, end day, # of pixel, index of pixel
                % 200 could change                
LakeReport = [LakeReport, Register_Area(3:end, temp)];
IntensityReport = [IntensityReport, Register_Intensity(:,temp)];

%========= save report =====

% % % % disp('stop saving files!!');
% % % % keyboard;

    if (year == 2000)
        save Report_1109_2000 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2001)
        save Report_1109_2001 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2002)
        save Report_1109_2002 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2003)
        save Report_1109_2003 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2004)
        save Report_1109_2004 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2005)
        save Report_1109_2005 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2006)
        save Report_1109_2006 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2007)
        save Report_1109_2007 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2008)
        save Report_1109_2008 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2009)
        save Report_1109_2009 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    elseif (year == 2010)
        save Report_1109_2010 LakeReport RegisterMap Register_Area Register_Area_Day Register_Intensity Top5PIceIntensity IntensityReport
    end
    
   
% ------------ plot ---------------
% % % % % % plot the brightness
% % % % % % Why use maximum instead of standard deviation:
% % % % % % The maximum could be the threshold settor
% % % % % figure(1); subplot(3,1,1);hist(AveBrightness( :,1), 100)
% % % % % title('average');
% % % % % figure(1); subplot(3,1,2);hist(AveBrightness(:,2), 100)
% % % % % title('Max');
% % % % % figure(1); subplot(3,1,3);hist(AveBrightness(:,2)./AveBrightness(:,1), 100)
% % % % % title('Max/average');
% % % % % 
% % % % % figure(2); subplot(4,1,1);hist(AveBrightness(:,2)./AveBrightness(:,1), 1:0.02:4);
% % % % % title(['Max/Average: (sza : all, ', num2str(min(AveBrightness(:,3))),'~',num2str(max(AveBrightness(:,3))),')' ]);
% % % % % Inx = (AveBrightness(:,3) < 70);
% % % % % figure(2); subplot(4,1,2);hist(AveBrightness(Inx,2)./AveBrightness(Inx,1), 1:0.02:4);
% % % % % title('Max/Average: sza < 70');
% % % % % Inx = (AveBrightness(:,3) < 60);
% % % % % figure(2); subplot(4,1,3);hist(AveBrightness(Inx,2)./AveBrightness(Inx,1), 1:0.02:4);
% % % % % title('Max/Average: sza < 60');
% % % % % Inx = (AveBrightness(:,3) < 50);
% % % % % figure(2); subplot(4,1,4);hist(AveBrightness(Inx,2)./AveBrightness(Inx,1), 1:0.02:4);
% % % % % title('Max/Average: sza < 50');


% % % % % plot the Area report
% % % % N_lakes = size(AreaReport,1);
% % % % for ii = 1:1:N_lakes
% % % %     vector = AreaReport(ii,:);
% % % %     N_days = vector(1);
% % % %     
% % % %     TT = vector(2:2:N_days*2);
% % % %     AA = vector(1+2:2:1+N_days*2);
% % % % 
% % % %     TT_plot = TT./max(TT);
% % % %     AA_plot = (AA - AA(1))./max(AA);
% % % %     figure(100); hold on; plot(TT_plot, AA_plot, 'r-', TT_plot, AA_plot, 'b.');
% % % % end
% % % % xlabel('time'); ylabel('area');

%%function [] = LakesAndRawData(data_noCM, Mask_noRock, inx_possibleLake, NotSignal)
% % % figure; imshow(data_noCM, [NotSignal, 1])
% % %         tt1 = double(data_noCM);
% % %         temp = zeros([size(tt1),3]);
% % % 
% % %         tt2 = tt1;
% % %         tt2(inx_possibleLake) = 1; %255; % red
% % %         tt2(Mask_noRock == 0) = 0;
% % %         temp(:,:,1) = tt2;
% % % 
% % %         tt2 = tt1;
% % %         tt2(inx_possibleLake) = 0;    
% % %         tt2(Mask_noRock == 0) = 0;
% % %         temp(:,:,2) = tt2;
% % %         temp(:,:,3) = tt2;    
% % % 
% % %         figure; imshow(temp, [NotSignal, 1]);
        

function [ChosenImg_TimeTag, Register_Area_Day] = ...
    calculate_ChosenImg_List(year, ref_rad, ch01_ch02, ...
    NotSignal, MOD02_Dir, MOD10_L2_Dir, Img_cc, Img_rr, ...
    Area_Thr, Bright_Thr, N_Bin, N_AvePoint, N_AvePoint_Deri, ...
    AlmostZero_1stDeri, Mask_ice_rock, Output_Dir_print, SaveTrackImg)

% mlock
Area_Thr_area = Img_rr * Img_cc * Area_Thr;

% MOD02_without_MOD10_L2 = {}; 

% % Ave_Max_Brightness_SZA = [];
% % % Ave_Max_Brightness_SZA = [Ave_Max_Brightness_SZA; ...
% % %     DD, ii, area_ratio, Ave_brightness, Max_brightness, sza];            
% % % save ch1_2009_Brightness_SZA Ave_Max_Brightness_SZA

% % % % % DaysWithAvailableImages = zeros(1, Day_end - Day_start + 1);

% % load LakeThr_ch1ch2
% LakeThr_ = [];
% load LakeThr


  
  % if no time tag in certain date, it means no suitable image found

ImgList = DIRR([MOD02_Dir, '*',num2str(year),'*',ref_rad,'*',ch01_ch02,'*.img']);
ImgList_MOD10 = DIRR([MOD10_L2_Dir, '*',num2str(year),'*snow*.img']);

N_MOD02 = size(ImgList,1);
N_MOD10 = size(ImgList_MOD10,1);

FirstFile = ImgList(1,1).name;
TimeTag_start = strfind(FirstFile, ['_',ref_rad]);
Day_start = str2double(FirstFile(TimeTag_start-8:TimeTag_start-6) );
    
LastFile = ImgList(end,1).name;
TimeTag_start = strfind(LastFile, ['_',ref_rad]);
Day_end = str2double( LastFile(TimeTag_start-8:TimeTag_start-6) );

%   ChosenImg_TimeTag = {}; % cellstr
  ChosenImg_TimeTag = cell(Day_end-Day_start+1,3); % cellstr
  % TimeTag, MOD02 file name, MOD10 file name
Register_Area_Day = zeros(Day_end-Day_start+1,1);%,5);
% %   % year, date, ave brightness, max brightness, sza (center point)
AvailableDay = 0;

  
ImgCount = 1;
ImgCandidate = zeros(15,5); % assume maximum # of image per day is less than 15
ImgCandidate_name = cell(15,2);

for DD = Day_start:1:Day_end

% % % %     fprintf(['\n    (Image Select) year: ',num2str(year),' Day : ',num2str(DD), '   '])    ;
%     ImgCandidate = [];    
%     ImgCandidate_name = {};
    
    % use reflectance in channel 2
    N_DayImg = 1;    

    
    TimeTag_start = strfind(ImgList(ImgCount,1).name, [num2str(year),num2str(DD),'_']);
    while (~isempty(TimeTag_start))
        
% % % % %     % ----- select the best image ------------   
% % % % %     for ii = 1:1:N_Img

% %         Current_Img = ImgList(ii,1).name;
        Current_Img = ImgList(ImgCount,1).name;

        % ----- ch1, reflectance
        fid = fopen([MOD02_Dir, Current_Img], 'rb');
        data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);
        data_noCM = data';

        Mask_signal = (data_noCM <= 1.0); % get rid of filled value from soruce data (3.3) and grided algorithm(65535).
        data_noCM(data_noCM >1.0) = NotSignal; % reflectance >1.0 is not a valid value

        % ---- cloud mask ----
        % use MOD10_L2 cloud mask

        TimeTag_start = strfind(Current_Img, [num2str(year),num2str(DD),'_']);
        TimeTag = Current_Img(TimeTag_start:TimeTag_start+11);

        for jj = 1:1:N_MOD10
            temp = strfind(ImgList_MOD10(jj,1).name, TimeTag);
            if ~isempty(temp)
                break;
            end
        end
      
        if isempty(temp) %---------------- still can't find the corresponding MOD10_L2....skip it
%             fprintf([' MOD02 which do not have MOD10_L2: ', TimeTag,'\n']); 
%             MOD02_without_MOD10_L2 = [MOD02_without_MOD10_L2; TimeTag,
%             Current_Img];
            
            ImgCandidate(N_DayImg, :) = [0 0 0 0 0];
%             ImgCandidate_name(N_DayImg, :) = [{''}, {''}]; % not
%             necessary

            N_DayImg = N_DayImg + 1; 
            ImgCount = ImgCount + 1;
            
            if (ImgCount <= N_MOD02) 
                TimeTag_start = strfind(ImgList(ImgCount,1).name, [num2str(year),num2str(DD),'_']);        
            else
                break;
            end
            
            continue;
        end
        
        Current_Img_MOD10 = ImgList_MOD10(jj,1).name; %<----------?? see if the file name is right        
        fid = fopen([MOD10_L2_Dir, Current_Img_MOD10], 'rb');
        data = fread(fid, [Img_cc, Img_rr], 'uint8');  fclose(fid);
        data_snow = data';
                                
        % get rid of filled value from soruce data (3.3), which could 
        % be "corrupted signal" & "cloud mask". 
        % But For cloud mask, the fill value
        % in the data_CM for grided algorithm is still 0 here.
                

%         Mask_noRock = Mask_signal .* (data_snow == 200); % no cloud, no rock, no bad signal
        Mask_noRock =( (Mask_signal==1) & (Mask_ice_rock==1) & (data_snow ~= 50));% no bad signal, no rock, no cloud
        
        % 200: snow cover land. could detect most of ice land, and exclude out cloudy area.
        %      . But some lakes are exclude out too.
        % 50 : cloud mask
        % 25: land. Lots lakes above ice are identified as land
        % http://nsidc.org/data/docs/daac/mod10_modis_snow/version_5/mod10l2_local_attributes.html#snowcoverpixelfield

        
% % %             figure(1); imshow(data_snow, [0, 255 ]);
% % %             figure(2); imshow(Mask_noRock, [0, 1]);
% % %             figure(3); imshow(data_noCM, [NotSignal, 0.9]);


        
% % % %         figure(1); subplot(1,8,N_DayImg);
% % % %         imshow(data_noCM.*Mask_noRock, [NotSignal,0.9]);
% % % % %         imshow(data_noCM, [NotSignal,0.9]);
% % % %         title([num2str(ImgCount)]);


        % ----------- choose the best picture for lake detection -----
        Mask_leftIce_area = sum(sum(Mask_noRock));
%         area_ratio = Mask_leftIce_area /Mask_ice_area;

        temp = data_noCM.*Mask_noRock;
        Ave_brightness = sum(sum(temp)) /Mask_leftIce_area;
%         Max_brightness = max(max(temp));
        
%             Max_Ave = max(max(temp)) / Ave_brightness; % Max / Average
% "max/ave" only matter when set threshold by max*0.6


% ----- blurring degree ----------- 
%  should compare based on the same region 
% 1st derivitive: birhghter image stand out
% normalize: darker image stand out
% current observation: blur image won't came out, but darker images did
% sometimes
% ps. a better way to do it should be calculate the 1st derivitive based on
% the same area. Without this step, area with more variation between dry
% ice and wet ice could have a higher 1st derivitive score.
% However, this method could possiblely compare blurness in a small area
% and it's troublesome that we need to go through all the possible area
% first. The most important thing is that the result might not much
% different.

        % ---------- manually identify the threshold of lake -----
% % % % %         if(0)
% % % % %             if (Mask_leftIce_area > Area_Thr_area && Ave_brightness > Bright_Thr) % && Ave_brightness < 0.3)
% % % % %                 % --- calculate the solar zenith angle. Based on the center of the images
% % % % %                 dn = str2double(Current_Img(11:13)); % Julienne day
% % % % %                 gmt = str2double(Current_Img(15:16)) + ...
% % % % %                         (str2double(Current_Img(17:18))/60); % GMT in decimal format
% % % % %                 sza = SolarZenithAngle(dn, gmt);        
% % % % % 
% % % % %                 Thr = 0.19; 
% % % % %                 WriteInFile = 0;
% % % % %                 while (WriteInFile ==0) % try to see the corelation of average threshold of lake, highest threshold of lake, and sza, brightness.
% % % % %                     Plot_AreaBelowThr(data_noCM, Thr, Mask_noRock, sza, NotSignal);
% % % % %                     keyboard;
% % % % %                 end
% % % % %                 LakeThr = [LakeThr; ...
% % % % %                     Thr, Ave_brightness, sza, DD, N_DayImg, Thr/Ave_brightness, Max_brightness];
% % % % %                 save LakeThr LakeThr
% % % % %             end
% % % % %         end

% % % if (Mask_leftIce_area ~=0) 
% % %     AveBrightness = [AveBrightness; brightness, max(max(temp)), sza];
% % % % %     figure(1); subplot(1,2,1);  imshow(data_noCM, [NotSignal, max(max(data_noCM)) ]);
% % % % %     figure(1); subplot(1,2,2);  imshow(temp, [NotSignal, max(max(temp)) ]);
% % % % %     title(['Brightness: ', num2str(brightness), '  ,max value: ', num2str(max(max(temp))), ...
% % % % %         ', ratio: ', num2str(max(max(temp)) /brightness )]);
% % % % %     keyboard;
% % %     
% % %     % set to 2.0 is the limit, smaller ratio = better image
% % % end

        % ----- only examine picture when area & brightness larger than
        % certain value -----
        if (Mask_leftIce_area > Area_Thr_area && Ave_brightness > Bright_Thr)
            
%             temp = data_noCM.*Mask_noRock * 100;
            temp = data_noCM .* 100;
            temp(Mask_noRock==0) = 0;
            
            % absolute (1st derivitive in row (2D image))
            Deri_1st_row = abs( temp(1:end-1, :) - temp(2:end,:) );
%             tempMask = Mask_noRock(1:end-1, :) + Mask_noRock(2:end, :); % origianl is ".*"
            Deri_1st_row = Deri_1st_row(...
                (Mask_noRock(1:end-1,:) == 1) & (Mask_noRock(2:end,:) ==1)); %tempMask == 2);

            % absolute (1st derivitive in column (2D image)) <----- could skip when
            % concerning time (derivitive in one direction should be enough)
            Deri_1st_col = abs( temp(:, 1:end-1) - temp(:, 2:end) ); 
%             tempMask = ((Mask_noRock(:, 1:end-1) == 1) & (Mask_noRock(:, 2:end) ==1)); % origianl is ".*"
            Deri_1st_col = Deri_1st_col(...
                (Mask_noRock(:, 1:end-1) == 1) & (Mask_noRock(:, 2:end) ==1)); %tempMask == 2);

            Ave_Deri_1st = mean([Deri_1st_row; Deri_1st_col])/Ave_brightness; 
            % average the 1st derivitive, normalized by Ave_brightness
            % % % title([num2str(ii), ': Ave. 1st Deri= ', num2str(Ave_Deri_1st*Ave_brightness), ', Ave Bright= ', num2str(Ave_brightness), ...
            % % %     ', after normalize= ',  num2str(Ave_Deri_1st) ]);

            % --- calculate the solar zenith angle. Based on the center of the images        
% % %             TimeTag_start = strfind(Current_Img, [num2str(year),num2str(DD),'_']);
% % %             TimeTag_hour = Current_Img(TimeTag_start+8:TimeTag_start+8+1);
% % %             TimeTag_min = Current_Img(TimeTag_start+8+2:TimeTag_start+8+3);
% % %             gmt = str2double(TimeTag_hour) + ...
% % %                 (str2double(TimeTag_min)/60); % GMT in decimal format
% % %             sza = SolarZenithAngle(DD, gmt); %DD = Julienne date
           
            % --- calcualte the percentage of spot/effective area ----
            [inx_possibleLake, message] = FindRoughSeed...
            (data_noCM, Mask_noRock, N_Bin, N_AvePoint, N_AvePoint_Deri, ...
            AlmostZero_1stDeri);

            if (isempty(message))
                SpotPercent = length(inx_possibleLake)/Mask_leftIce_area;
            else % with message, no spot found
                SpotPercent = 0;
            end
        
            
            ImgCandidate(N_DayImg, :) = ...
                [ImgCount, Mask_leftIce_area, Ave_Deri_1st, ...
                Ave_brightness, SpotPercent]; %, Max_brightness, sza];
% %             ImgCandidate = [ImgCandidate; ...
% %                 ImgCount, Mask_leftIce_area, Ave_Deri_1st, ...
% %                 Ave_brightness, SpotPercent, Max_brightness, sza];
            ImgCandidate_name(N_DayImg, :) = [{Current_Img}, {Current_Img_MOD10}]; %{Current_Img_MOD35}];
% %             ImgCandidate_name = [ImgCandidate_name; ...
% %                 {Current_Img}, {Current_Img_MOD10}]; %{Current_Img_MOD35}];

% %             temp = data_noCM.*Mask_noRock;
% %             figure(1); subplot(1,N_Img, ii); imshow(temp, [NotSignal, max(max(temp)) ]); 
% %             title([num2str(ii), ' ',num2str(Ave_brightness), ' ', num2str(Ave_Deri_1st) ]);
        else            
            ImgCandidate(N_DayImg, :) = [0 0 0 0 0];
%             ImgCandidate_name(N_DayImg, :) = [{''}, {''}]; % not
%             necessary
        end
        
        N_DayImg = N_DayImg + 1; 
        ImgCount = ImgCount + 1;

        if (ImgCount <= N_MOD02) 
            TimeTag_start = strfind(ImgList(ImgCount,1).name, [num2str(year),num2str(DD),'_']);
        else
            break;
        end
    end
        
    N_DayImg = N_DayImg - 1; % # of image of day DD

%     UseInx = ImgCandidate(1:N_DayImg,1) > 0;
%     if (~any(UseInx)) % fprintf(' No suitable image found\n');
    if (~any(ImgCandidate(1:N_DayImg,1) > 0)) % fprintf(' No suitable image found\n');
        continue;
    end        
    
    % combine the effect of both area(2), blurness(3), brightness(4),
    % percentage of spot (5)



%     if (max(ImgCandidate(UseInx,5)) ==0)
    if (any(ImgCandidate(1:N_DayImg,5) > 0) ) % at lest one image have spots
        temp = ImgCandidate(1:N_DayImg,2:5);
        temp2 = max(temp, [], 1);
        temp = sum(temp./repmat(temp2,N_DayImg,1), 2);

% % % % %         temp = ImgCandidate(1:N_DayImg,2)/max(ImgCandidate(1:N_DayImg,2)) + ... % Mask_leftIce_area
% % % % %             ImgCandidate(1:N_DayImg,3)/max(ImgCandidate(1:N_DayImg,3)) + ... % Ave_Deri_1st
% % % % %             ImgCandidate(1:N_DayImg,4)/max(ImgCandidate(1:N_DayImg,4)) + ... % Ave_brightness
% % % % %             ImgCandidate(1:N_DayImg,5)/max(ImgCandidate(1:N_DayImg,5)); % percentage of spots
%             <---- maximum average brightness will get cloudy area, and

        [~, ChosenInx] = max(temp);
% %         Ave_brightness = ImgCandidate(ChosenInx,4);
% %         ChosenImg = ImgCandidate(ChosenInx,1); % index(1)
% %         Current_Img = ImgList(ChosenImg,1).name;

% % % %     if (ImgCandidate(ChosenInx,5) ==0)
% % % % % %         fprintf('no spot in the best image, not report\n');
% % % %         continue;
% % % %     end
        
        Current_Img = char(ImgCandidate_name(ChosenInx,1)); % MOD02 file name

        if (SaveTrackImg == 1)
        % ----- ch1, reflectance ---- output raw image
        fid = fopen([MOD02_Dir, Current_Img], 'rb');
        data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);
        data_noCM = data';
        data_noCM(data_noCM >1.0) = NotSignal; % reflectance >1.0 is not a valid value    
    
        tttt = uint8(255 .* (data_noCM/0.9));
        imwrite(tttt, [Output_Dir_print, num2str(year), num2str(DD), '.png'], 'PNG');
        end
    
        TimeTag_start = strfind(Current_Img, [num2str(year),num2str(DD),'_']);
        TimeTag = Current_Img(TimeTag_start+8:TimeTag_start+8+3);

        AvailableDay = AvailableDay + 1;

% %         ChosenImg_TimeTag = [ChosenImg_TimeTag; ...
% %             TimeTag, ImgCandidate_name(ChosenInx,:)];

        ChosenImg_TimeTag(AvailableDay, :) = [TimeTag, ImgCandidate_name(ChosenInx,:)];


        % TimeTag, MOD02 file name, MOD10_L2 file name
        Register_Area_Day(AvailableDay) = DD;
%                 [year, DD, ImgCandidate(ChosenInx,4:6)];
        % average brightness , Maximum brightness, sza (center point)
        
% %     fprintf(['image:',num2str(ImgCandidate(ChosenInx,1)),...
% %             '  ',num2str(year),num2str(DD), '\n']);
    
    else      % no spot in any image, still list it, but mark it as spotless
% %         fprintf('no spot in any image, not report\n');
% still print out, but don't do the analysis on it

        temp = ImgCandidate(1:N_DayImg,2:4);
        temp2 = max(temp, [], 1);
        temp = sum(temp./repmat(temp2,N_DayImg,1), 2);

% %         temp = ImgCandidate(1:N_DayImg,2)/max(ImgCandidate(1:N_DayImg,2)) + ... % Mask_leftIce_area
% %             ImgCandidate(1:N_DayImg,3)/max(ImgCandidate(1:N_DayImg,3)) + ... % Ave_Deri_1st
% %             ImgCandidate(1:N_DayImg,4)/max(ImgCandidate(1:N_DayImg,4)); % Ave_brightness

        [~, ChosenInx] = max(temp);
        Current_Img = char(ImgCandidate_name(ChosenInx,1)); % MOD02 file name

        if (SaveTrackImg == 1)
            % ----- ch1, reflectance --- output raw image
            fid = fopen([MOD02_Dir, Current_Img], 'rb');
            data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);
            data_noCM = data';
            data_noCM(data_noCM >1.0) = NotSignal; % reflectance >1.0 is not a valid value    

            tttt = uint8(255 .* data_noCM/0.9);
            imwrite(tttt, [Output_Dir_print, num2str(year), num2str(DD), '_noSpot.png'], 'PNG');
        end
    end

end

ChosenImg_TimeTag = ChosenImg_TimeTag(1:AvailableDay, :);
Register_Area_Day = Register_Area_Day(1:AvailableDay);
% get rid of the first temporary one, which is used for create the string cell  




function [Mask_ice_area, Mask_ice_rock] = MOD10_L2_IceRockMask ...
        (ZeroMap_long, MOD10_L2_Dir, Img_cc, Img_rr, KERNEL, ...
        year, Area_Thr) %, MapNoIsland)
% mlock

Img_rrcc = Img_cc * Img_rr;    
Mask_ice_rock = ZeroMap_long;
Area_Thr_area = Img_rrcc * Area_Thr;
ImgList_MOD10 = DIRR([MOD10_L2_Dir, '*',num2str(year),'*snow*.img']);
N_MOD10 = size(ImgList_MOD10,1);

Count = 0;
for ii = 1:1:N_MOD10

    temp = str2double(ImgList_MOD10(ii,1).name(14:16)); % <=================================== 14:16 is go with the format of file name. if name format of Cloud Mask change, this part need to change
    
    if (temp > 151) % && temp < 245) % only average images within June, July, and August or later

        fid = fopen([MOD10_L2_Dir, ImgList_MOD10(ii,1).name], 'rb');   
        data = fread(fid, [Img_rrcc,1], 'uint8'); fclose(fid);
        
        % 200: snow cover land. could detect most of ice land, and exclude out cloudy area.
        %      . But some lakes are exclude out too.
        % 50 : cloud mask
        % 25: land. Lots lakes above ice are identified as land
        % http://nsidc.org/data/docs/daac/mod10_modis_snow/version_5/mod10l2_local_attributes.html#snowcoverpixelfield

        % ----------- choose pictures with ice area larger than threshold ------
        temp = (data == 200);
        Mask_leftIce_area = sum(temp);

        if (Mask_leftIce_area > Area_Thr_area)
            Count = Count + 1;
            Mask_ice_rock = Mask_ice_rock + temp; %Mask;
        end    
    end
        
end

    Mask = reshape(Mask_ice_rock, Img_cc, Img_rr); 
    temp = Count/2;
    Mask(Mask_ice_rock <= temp) = 0;
    Mask(Mask_ice_rock > temp) = 1;
    
    Mask = Mask';
%     Mask_BeforeDilationErosion = Mask;

% figure; imshow(Mask, [0,1]); title([num2str(year), 'before: ice/rock
% mask']);
    
    % ------ eliminate the small grants in the cloud Mask -------

%         figure(5); imshow(Mask, [0,1]);
%         keyboard;

    for jj = 1:1:1 %Dilation % get rid of small dots
        Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
        Mask = (Mask_temp > 0);
% %         figure(5); imshow(Mask, [0,1]);        
% %         keyboard;
    end
    for jj = 1:1:15 %erosion % get it back
        Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
        Mask = (Mask_temp == 9);
    end

    for jj = 1:1:8 %Dilation % get rid of small dots
        Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
        Mask = (Mask_temp > 0);
    end
    

%     figure; imshow(Mask, [0,1]); title([num2str(year),'after: ice/rock mask']);    

    % ------- get rid of small land, only keep the largest ice sheet -----
    [LabelMap, cluster] = LabelCluster(Img_rr, Img_cc, uint8(Mask));

    LandArea_Count = zeros(cluster,1); % record area of each group of land
    for ii = 1:1:Img_rrcc
        temp = LabelMap(ii);
        if temp ~=0
            LandArea_Count(temp) = LandArea_Count(temp)+1; % original area + 1
        end        
    end

    [~,LL] = max(LandArea_Count);

    Mask_ice_rock = double(LabelMap == LL);    
    Mask_ice_area = sum(sum(Mask_ice_rock));   
    
% % % %     temp = (Mask_ice_rock==1 & MapNoIsland==1);
% % % %     Mask_ice_rock = double(temp);
    
%      figure; imshow(Mask_ice_rock, [0,1]); title([num2str(year),'after remove small land(s)']);


               
%% plot routine (to find the highest reflectance of each image)
%%function [] = Plot_AreaBelowThr_ch1ch2(Ch1,Ch1Ch2, Thr, MaskIncludeRock, sza, NotSignal)
% % % %     figure(200);     imshow(Ch1.*MaskIncludeRock, [NotSignal, 1]);
% % % %     AboveThrArea = (Ch1Ch2 >  Thr);
% % % %     figure(201);    imshow(AboveThrArea, [0, 1]);
% % % %     title(['Red: area below ', num2str(Thr), ', sza:',num2str(sza),')']);

    
%%function [] = Plot_AreaBelowThr_compareCh1Ch2...
% % %     (Ch1, Ch2, Thr_1, Thr_2, MaskIncludeRock, sza, NotSignal)
% % %     
% % % for ii = 1:1:2
% % %     
% % %     if ii == 1
% % %         InpF = Ch1;    Thr = Thr_1;
% % %     else
% % %         InpF = Ch2;    Thr = Thr_2;
% % %     end
% % %     % ---- channel 1 or 2 -------    
% % %     figure(200); subplot(1,2,ii);  imshow(InpF.*MaskIncludeRock, [NotSignal, 1]);
% % % 
% % %     tt1 = double(InpF);
% % %     temp = zeros([size(tt1),3]);
% % %     BelowThrArea = (InpF<= Thr);
% % %     
% % %     tt2 = tt1;
% % %     tt2(BelowThrArea) = 255; % red
% % %     tt2(MaskIncludeRock == 0) = 0;
% % %     temp(:,:,1) = tt2;
% % % 
% % %     tt2 = tt1;
% % %     tt2(BelowThrArea) = 0;    
% % %     tt2(MaskIncludeRock == 0) = 0;
% % %     temp(:,:,2) = tt2;
% % %     temp(:,:,3) = tt2;    
% % % 
% % %     figure(201);  subplot(1,2,ii);  imshow(temp, [NotSignal, 1]);
% % % 
% % %     % ------
% % %     Mask_leftIce_area = double(MaskIncludeRock .* (InpF>Thr));
% % %     temp = InpF.*Mask_leftIce_area;
% % %     Ave_brightness_new = sum(sum(temp))/sum(sum(Mask_leftIce_area));
% % %     
% % %     title(['Red: area below ', num2str(Thr),...
% % %         ' (Ave_bright: ', num2str(Ave_brightness_new),', sza:',num2str(sza),')']);
% % % end
    
    
%%function [] = Plot_AreaBelowThr(InpF, Thr, MaskIncludeRock, sza, NotSignal)
% % % % gray scale image
% % %     tt1 = double(InpF);
% % %     figure(200);     imshow(InpF.*MaskIncludeRock, [NotSignal, 1]);
% % % 
% % %     temp = zeros([size(tt1),3]);
% % %     BelowThrArea = (InpF<= Thr);
% % %     
% % %     tt2 = tt1;
% % %     tt2(BelowThrArea) = 255; % red
% % %     tt2(MaskIncludeRock == 0) = 0;
% % %     temp(:,:,1) = tt2;
% % % 
% % %     tt2 = tt1;
% % %     tt2(BelowThrArea) = 0;    
% % %     tt2(MaskIncludeRock == 0) = 0;
% % %     temp(:,:,2) = tt2;
% % %     temp(:,:,3) = tt2;    
% % % 
% % %     figure(201);    imshow(temp, [NotSignal, 1]);
% % % 
% % %     Mask_leftIce_area = double(MaskIncludeRock .* (InpF>Thr));
% % %     temp = InpF.*Mask_leftIce_area;
% % %     Ave_brightness_new = sum(sum(temp))/sum(sum(Mask_leftIce_area));
% % %     
% % %     title(['Red: area below ', num2str(Thr),...
% % %         ' (Ave_bright: ', num2str(Ave_brightness_new),', sza:',num2str(sza),')']);
% % % % is lake reflectance different in different location? hightest lake
% % % % reflectance for each angle (is the gap decress in darker image?)

%% Solar Zenith Angle, input day number and Greenwithmean time
%%function [sza] = SolarZenithAngle(dn, gmt) 
% % % pi=3.141592654;
% % % rad=pi/180;
% % % deg=180/pi;
% % % lat = 69.25;
% % % lon = -50;
% % % 
% % % lat=lat*rad;        
% % % da=2*pi*(dn-1)/365;
% % % soldec=(0.006918-0.399912*cos(da)+0.070257*sin(da)-0.006758*cos(2*da)+0.000907*sin(2*da)-0.002697*cos(3*da)+0.00148*sin(3*da));
% % % et=(0.000075+0.001868*cos(da)-0.032077*sin(da)-0.014615*cos(2*da)-0.04089*sin(2*da))*(229.18);
% % % solt=gmt+((lon*4)/60)+et/60;
% % % ha=(12-solt)*(pi/12);
% % % cos_solzen=sin(soldec)*sin(lat)+cos(soldec)*cos(lat)*cos(ha);
% % % sza = acos(cos_solzen)*deg;



function [IsLake, Corr_Inx, A2] = IsCorrespondQ_2(R_Inx, A1, N2)
% mlock
% with R_Inx from Map1, find all the corresponding labels respect to Inx in Map2.
% see if sum of the corresponding lakes are qualified lakes
% the desicion (IsLake), and the corresponding lable list

% A1 = length(Map1(R_Inx)); 
% ----- merge label and merge area in Map1 for R_Inx

global LakeLookUp LakeInxS_Add1
global Layers_LabelMap

Map = Layers_LabelMap(:,N2); %Map2;
LookUp = LakeLookUp(:,N2);

Corr = Map(R_Inx);
Corr = Corr(Corr>0);
Corr_Inx = [];

CorrLabel = zeros(20,1);
N_label = 0;

A2 = 0;
    
    if (~isempty(Corr) )
        Corr = sort(Corr, 'ascend'); % corresponding labels, might with repeated label                    

        N_label = N_label + 1;
        CorrLabel(N_label) = Corr(1);
        
        temp = (Corr(1)-1)* LakeInxS_Add1;
        A2 = LookUp(temp+1);
        Corr_Inx = LookUp(temp+2:temp+1+A2);
        
        if ( any(Corr ~= Corr(1)) ) % more than 1 label is mapped
            for jj = 2:1:length(Corr) % find label                                            
                if ( Corr(jj) ~= Corr(jj-1) )
                    N_label = N_label + 1;
                    CorrLabel(N_label) = Corr(jj);

                    temp = (Corr(jj)-1)* LakeInxS_Add1;
                    tempA = LookUp(temp+1);                    
                    Corr_Inx = [Corr_Inx; LookUp(temp+2:temp+1+tempA)];
                    A2 = A2 + tempA;
                end
            end
        end
    end
    
% CorrLabel = CorrLabel(1:N_label);
% ---- examine the area -------
if ( (A2 < 2*A1 + 8) && (A2 > A1/2) ) % positive
    IsLake = 1;
else
    IsLake = 0;
end        


% function [IsLake, CorrInx1, CorrInx2] = IsCorrespondQ_Inx(R_Inx, Map1, Map2)
function [IsLake, CorrInx1, CorrInx2, A1, A2] = ...
    IsCorrespondQ_1_2(R_Inx, N1, N2)
% mlock
% find all the corresponding labels respect to Inx in L1.
% see if sum of the corresponding lakes are qualified lakes
% 10year the desicion (IsLake), and the corresponding lable list

% A1 = length(Map1(R_Inx)); 
% ----- merge label and merge area in Map1 for R_Inx

global LakeLookUp LakeInxS_Add1
global Layers_LabelMap

for ii = 1:1:2
    if ii == 1
        Map = Layers_LabelMap(:,N1); %Map1;
        LookUp = LakeLookUp(:,N1);
    else
        Map = Layers_LabelMap(:,N2); %Map2;
        LookUp = LakeLookUp(:,N2);
    end
    
    Corr = Map(R_Inx);
    Corr = Corr(Corr>0);
    Corr_Inx = [];

    CorrLabel = zeros(20,1);
    N_label = 0;

    A = 0;
    
    if (~isempty(Corr) )
        Corr = sort(Corr, 'ascend'); % corresponding labels, might with repeated label                    

        N_label = N_label + 1;
        CorrLabel(N_label) = Corr(1);
        
        temp = (Corr(1)-1)* LakeInxS_Add1;
        A = LookUp(temp+1);
        Corr_Inx = LookUp(temp+2:temp+1+A);
        
        if ( any(Corr ~= Corr(1)) ) % more than 1 label is mapped
            for jj = 2:1:length(Corr) % find label                                            
                if ( Corr(jj) ~= Corr(jj-1) )
                    N_label = N_label + 1;
                    CorrLabel(N_label) = Corr(jj);

                    temp = (Corr(jj)-1)* LakeInxS_Add1;
                    tempA = LookUp(temp+1);                    
                    Corr_Inx = [Corr_Inx; LookUp(temp+2:temp+1+tempA)];
                    A = A + tempA;
                end
            end
        end
    end
    
    if ii == 1
        CorrInx1 = Corr_Inx;        
        A1 = A;
%         CorrLabel1 = CorrLabel(1:N_label);
    else
        CorrInx2 = Corr_Inx;
        A2 = A;
%         CorrLabel2 = CorrLabel(1:N_label);
    end
    
end

% ---- examine the area -------
if ( (A2 < 2*A1 + 8) && (A2 > A1/2) ) % positive
    IsLake = 1;
else
    IsLake = 0;
end            

function  [Darkest, Top5P, Avg] = CalIntensity(N_img, index)
% mlock        
% % % global O1 O2 O3 O4 O5 O6
% % % 
% % %         if N_img == 1
% % %             AllIntensity = O1(index);
% % %         elseif N_img == 2
% % %             AllIntensity = O2(index);
% % %         elseif N_img == 3
% % %             AllIntensity = O3(index);
% % %         elseif N_img == 4
% % %             AllIntensity = O4(index);
% % %         elseif N_img == 5
% % %             AllIntensity = O5(index);
% % %         elseif N_img == 6
% % %             AllIntensity = O6(index);        
% % %         end
        
global Layers_refData
AllIntensity = Layers_refData(index, N_img);

        temp = sort(AllIntensity, 'ascend');
        Darkest = temp(1);
        Top5P = temp(ceil(length(temp) * 0.05));
        Avg = mean(AllIntensity);

%% found 1 pair (any 2 days) in 6 days (include cloudy day)
% the 3rd day will take care in the function "TrackLake"
function [] = InitiateLake(DayInx1to6, N_ChosenImg)

% mlock
global RegisterMap Register_Area Register_Intensity
global Layers_LabelMap
global LakeLookUp LakeInxS_Add1

Register_Area_buffer = zeros(3+N_ChosenImg+300, 200); % assume maximum for 4 year is 82
Register_Intensity_buffer = zeros(N_ChosenImg*3, 200); % assume maximum for 4 year is 82

N_newLake = 0;
N_existLake = size(Register_Area,2);

ZeroArea = zeros(N_ChosenImg,1);
Zero6 = zeros(6,1);
    
temp = sum((Layers_LabelMap>0),2);
MaybeLake_Map = (temp>=2 & RegisterMap == 0);
MaybeLake = find(MaybeLake_Map == 1);
Len = length(MaybeLake);
    
for MM = 1:1:Len    

    tempInx_1 = MaybeLake(MM);    
    if MaybeLake_Map(tempInx_1) == 0
        continue;
    end
    
    Lake = Layers_LabelMap(tempInx_1,:);    

    % ---- find the index and layer with maximun area ----
%     R_Inx = []; % standard index, we choose the largest one
% don't need to initialized it. There are at lest 2 frames with area.
    MaxArea = 0;
    for ii = 1:1:6        
        if (Lake(ii) > 0)                  
            temp = (Lake(ii)-1)* LakeInxS_Add1;
            A = LakeLookUp(temp+1, ii); % area
            if MaxArea < A
                MaxArea = A;
                R_Inx = LakeLookUp(temp+2:temp+1+A, ii);
            end            
        end
    end
    
    % ---- use R_Inx as standard, find the corresponding lakes in 6 frames
    % --- find the layer with non-zero label ----
    appear3 = Zero6;
    temp = find(any(Layers_LabelMap(R_Inx, :)~=0, 1));
    appear3(1:length(temp)) = temp;
    
    % ------ find corresponding for the 1st frame with label ----
    IsLake = 0;
    temp1 = appear3(1);
    ii = 2;
        
    while (IsLake == 0 && ii<=6 && appear3(ii) ~=0 )          
        temp2 = appear3(ii);
        [IsLake, CorrInx1, CorrInx2, A1, A2] = ...
            IsCorrespondQ_1_2(R_Inx, temp1, temp2);
        ii = ii+1;
    end
    
    if (IsLake == 1) % found the corresponding pair

        if (any(RegisterMap(CorrInx2) ~= 0) ) % have registered, skip
            MaybeLake_Map(tempInx_1) = 0;
            continue;
        end
        
        N_newLake = N_newLake + 1;
        RegisterMap(CorrInx2) = N_existLake+N_newLake; % haven't establish
        
        % ---- Register_Area -----
        temp_Area = ZeroArea;        
        temp_Area( DayInx1to6(temp1) ) = A1; %length(CorrInx1);
        
        if DayInx1to6(temp1)+1~=DayInx1to6(temp2)            
            temp_Area( DayInx1to6(temp1)+1:DayInx1to6(temp2)-1 ) = -1*A1; %length(CorrInx1);
        end
        
%         LastArea = A2; %length(CorrInx2);
        temp_Area( DayInx1to6(temp2) ) = A2;%LastArea;

        Register_Area_buffer(:,N_newLake) = ...
            [-5; DayInx1to6(temp2); A2; temp_Area;CorrInx2; zeros(300-A2,1)];
        
        % ---------- Register_Intensity ---------
        temp_Inten = [ZeroArea; ZeroArea; ZeroArea];
                
        [Darkest, Top5P, Avg] = CalIntensity(temp1, CorrInx1); 
        temp_Inten(DayInx1to6(temp1) ) = Darkest;
        temp_Inten(DayInx1to6(temp1)+N_ChosenImg ) = Top5P;
        temp_Inten(DayInx1to6(temp1)+N_ChosenImg*2 ) = Avg;
        
        [Darkest, Top5P, Avg] = CalIntensity(temp2, CorrInx2); 
        temp_Inten(DayInx1to6(temp2) ) = Darkest;
        temp_Inten(DayInx1to6(temp2)+N_ChosenImg ) = Top5P;
        temp_Inten(DayInx1to6(temp2)+N_ChosenImg*2 ) = Avg;
                
        Register_Intensity_buffer(:,N_newLake) = temp_Inten;

% % % % %         if length(CorrInx1) < length(CorrInx2)
% % % % %             MaxArea = length(CorrInx2);
% % % % %             recordArea = CorrInx2;
% % % % %         else
% % % % %             MaxArea = length(CorrInx1);
% % % % %             recordArea = CorrInx1;
% % % % %         end
% % % % %         
% % % % %         Register_Area = [Register_Area; ...
% % % % %             -5, DayInx1to6(temp2), MaxArea, temp_Area,recordArea', zeros(1,300-MaxArea)];
        % un-established left day, examine day index, maximum area, 
        % area record in each day, index of maximum lake

        % ---- don't search repeatedly -----
        MaybeLake_Map(R_Inx) = 0; % we have registerd 2nd appear day,
% %         MaybeLake_Map(CorrInx1) = 0; % we have registerd 2nd appear day,
% %         MaybeLake_Map(CorrInx2) = 0; % we have registerd 2nd appear day,
        % and it should cover the overlapped area. Get rid of it for the
        % search range.
        
    else
        MaybeLake_Map(tempInx_1) = 0;
    end            
end

Register_Area = [Register_Area, Register_Area_buffer(:, 1:N_newLake)];
Register_Intensity = [Register_Intensity, Register_Intensity_buffer(:, 1:N_newLake)];


function [LakeReport_temp, IntensityReport_temp, N_merge] = ...
    TrackLake(DayInx1to6, N_ChosenImg, N_merge, ...
    Register_Area_Day, SaveTrackImg, Output_Dir_temporal, year) 
% mlock

global RegisterMap Register_Area Register_Intensity
global CloudFreeGroup_5 CloudFreeGroup_6
global Layers_LabelMap

LakeReport_temp = zeros(1+N_ChosenImg+300, 200); % for 4 year data, maximum is 60
IntensityReport_temp = zeros(N_ChosenImg*3, 200);

N_ReportLake = 0;

% for new lake, the merge one
% some lake merge and futher merge in the same image....don't use this
% % % Register_Area_buffer = zeros(3+N_ChosenImg+300, 100); % new lake, maximum for 4 year is 82 in InitiateLake
% % % N_newLake = 0;
% % % N_existLake = size(Register_Area,2);

clutser = size(Register_Area, 2);
Zero6 = zeros(1,6);
Day1Inx = DayInx1to6(1);
ZeroArea = zeros(N_ChosenImg,1);
% % ZeroMap_long = zeros(Img_rr*Img_cc,1); %% speed up, start from here

% PlotLake: start day, end day, area, index (300 with zero padding)
if (SaveTrackImg == 1)    
    PlotLake = zeros(3+300, 500); 
    N_Lake = 0;
end

for cc = 1:1:clutser

%    R_Inx = (RegisterMap == cc);    

    leftDay = Register_Area(1,cc);

         % the examine day is 1st day or not || lake has merged in the middle
    if(Register_Area(2,cc) ~= Day1Inx || leftDay == 0)
        continue;
    end

    % (leftDay ~= 0) % Still there, haven't destroied
    R_Area = Register_Area(3,cc);
    R_Inx = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+R_Area,cc);
    
    

        
    % --- find the layer with non-zero label ----
    appear3 = Zero6;
%     appear3(1) = 1;
% %     temp=2;
    temp = any(Layers_LabelMap(R_Inx, 2:end)~=0, 1);
    temp = find([1,temp]);
    appear3(1:length(temp) ) = temp;

% %     if ( any(L2(R_Inx) ~=0) )  % are there corresponding lable in each layer
% %         appear3(temp) = 2;  temp = temp+1;
% %     end
% %     if ( any(L3(R_Inx) ~=0) )  % are there corresponding lable in each layer
% %         appear3(temp) = 3;  temp = temp+1;
% %     end
% %     if ( any(L4(R_Inx) ~=0) )  % are there corresponding lable in each layer
% %         appear3(temp) = 4;  temp = temp+1;
% %     end
% %     if ( any(L5(R_Inx) ~=0) )  % are there corresponding lable in each layer
% %         appear3(temp) = 5;  temp = temp+1;
% %     end
% %     if ( any(L6(R_Inx) ~=0) )  % are there corresponding lable in each layer
% %         appear3(temp) = 6;
% %     end

    % ------ there is no mapped spot in the following 5 images ----
    % count how many miss clear day, and go to next one
    if (appear3(2)==0) 
        
        MissClearDay = min(CloudFreeGroup_5(R_Inx));
        
        if (leftDay < 0) % lake only appear twice, haven't establish
            leftCount = (leftDay*-1) - MissClearDay;
            
            if (leftCount <= 0) % miss in 5 "clear" days. destroy and do not record it
%                 RegisterMap(RegisterMap == cc) = 0;
                A = Register_Area(3,cc);
                tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,cc);
                RegisterMap(tt(RegisterMap(tt)==cc)) =0;
                
                Register_Area(1,cc) = 0;
            else
                Register_Area(1,cc) = leftCount*-1;
                Register_Area(2,cc) = DayInx1to6(6); % update examine day
            end
        else % established lakes
            leftCount = leftDay - MissClearDay;

            if (leftCount <= 0) % miss in 5 "clear" days. Disappear. stop record it and report it.
                temp = Register_Area(3,cc); % recorded area
                N_ReportLake = N_ReportLake+1;
                LakeReport_temp(:,N_ReportLake) = ... % Register_Area(3:end,cc); % <--- consider also the last two labels
                    [Register_Area(3:3+N_ChosenImg+temp,cc); zeros(300-temp-2,1); Register_Area(end-1:end,cc)];
%                    [Register_Area(3:3+N_ChosenImg+temp,cc); zeros(300-temp,1)];
                IntensityReport_temp(:,N_ReportLake) = Register_Intensity(:,cc);

%                 RegisterMap(RegisterMap == cc) = 0;
                A = Register_Area(3,cc);
                tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,cc);
                RegisterMap(tt(RegisterMap(tt)==cc)) =0;
                
                Register_Area(1,cc) = 0;
                
                
% % % %                 ??????????????????????????
% % % %                 if (SaveTrackImg == 1) % plot the result
% % % %                     N_Lake = N_Lake + 1;
% % % %                     Area = Register_Area(3,cc);
% % % %                     PlotLake(1:3+Area,N_Lake) = ...
% % % %                         [LastAppear_DayInx; (DayInx1to6(temp2)-1); Area; ... 
% % % %                         Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+Area,cc)];  
% % % %                     % use maximum area
% % % %                     %start day, end day, area, index (300 with zero
% % % %                     %padding)
% % % %                 end
                
            else
                Register_Area(1,cc) = leftCount;
                Register_Area(2,cc) = DayInx1to6(6); % update examine day
            end
        end
        continue;
    end
                
    % ----- find corrsponding lake for the following spot -----
    IsLake = 0;
    ii = 2;    
            
    % standard must be L1 here, since this is the examining day
    while (IsLake == 0 && ii<=6 && appear3(ii) ~=0 )          
        temp2 = appear3(ii);
        [IsLake, CorrInx2, A2] = ...
            IsCorrespondQ_2(R_Inx, R_Area, temp2);
        ii = ii+1;
    end
        
    CorrInx1 = R_Inx;
    A1 = R_Area;
    
    if (IsLake == 1) % found the 1 corresponding lake, keep tracking it

        tempInx = RegisterMap(CorrInx2);
        tempInx = tempInx(tempInx>0);
        tempInx = sort(tempInx, 'ascend');
        
        % more than 1 label are corresponding lakes --> merge
        if any(tempInx ~= tempInx(1)) 
            % --- output collided small lakes, no matter established or not
            
            N_merge = N_merge+1;
            
            LL = tempInx(1);
            % put negative area for ploting later on 
            % don't put any area on the merged day
            LastAppear_DayInx = find(Register_Area(3+1:3+DayInx1to6(temp2)-1,LL), 1,'last');
            
            if ~isempty(LastAppear_DayInx) 
                % it's empty when lake first appear on the DayInx1to6(temp2)
                % we don't report or plot it, just destroy it. it will be take care by the
                % merged lake                                            
                if LastAppear_DayInx+1 ~= DayInx1to6(temp2)
                    Register_Area(3+LastAppear_DayInx+1:3+DayInx1to6(temp2)-1, LL) ...
                        = -1*Register_Area(3+LastAppear_DayInx,LL);
                end
                
                N_ReportLake = N_ReportLake+1;
                LakeReport_temp(:,N_ReportLake) = ...
                    [Register_Area(3:3+N_ChosenImg+300-1,LL); N_merge];
                IntensityReport_temp(:,N_ReportLake) = Register_Intensity(:,LL);
                
                if (SaveTrackImg == 1)    
                    N_Lake = N_Lake + 1;
                    Area = Register_Area(3,LL);
                    PlotLake(1:3+Area,N_Lake) = ...
                        [LastAppear_DayInx; (DayInx1to6(temp2)-1); Area; ...
                        Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+Area,LL)];  
                    % use maximum area
                    %start day, end day, area, index (300 with zero
                    %padding)
                end
            end
            
%             RegisterMap(RegisterMap == LL) = 0;
            A = Register_Area(3,LL);
            tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,LL);
            RegisterMap(tt(RegisterMap(tt)==LL)) =0;
            
            Register_Area(1,LL) = 0;                    
                    
            Len = length(tempInx);
            for uu = 2:1:Len
                if tempInx(uu) ~= tempInx(uu-1)
                    LL = tempInx(uu);

                    LastAppear_DayInx = find(Register_Area(3+1:3+DayInx1to6(temp2)-1,LL), 1,'last');       
                    if ~isempty(LastAppear_DayInx) 
                        % it's empty when lake first appear on the DayInx1to6(temp2)
                    % we don't report or plot it, just destroy it. it will be take care by the
                    % merged lake                                            
                    
                        if LastAppear_DayInx+1 ~= DayInx1to6(temp2)
                            Register_Area(3+LastAppear_DayInx+1:3+DayInx1to6(temp2)-1,LL) ...
                                = -1*Register_Area(3+LastAppear_DayInx,LL);
                        end
                        N_ReportLake = N_ReportLake+1;
                        LakeReport_temp(:,N_ReportLake) = ...
                            [Register_Area(3:3+N_ChosenImg+300-1,LL); N_merge]; % not clean up. could be more "# of lake index" than "area"
                        IntensityReport_temp(:,N_ReportLake) = Register_Intensity(:,LL);

                        if (SaveTrackImg == 1)    
                        N_Lake = N_Lake + 1;
                        Area = Register_Area(3,LL);
                        PlotLake(1:3+Area,N_Lake) = ...
                            [LastAppear_DayInx; (DayInx1to6(temp2)-1); Area; ...
                            Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+Area,LL)];  
                        % use maximum area
                        end                    
                    end
                    
%                     RegisterMap(RegisterMap == LL) = 0;
                    A = Register_Area(3,LL);
                    tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,LL);
                    RegisterMap(tt(RegisterMap(tt)==LL)) =0;
                    
                    Register_Area(1,LL) = 0;
                end
            end
            
            % ----- establish new lake -------
%             LastArea = A2; %length(CorrInx2);
            temp_Area = ZeroArea;        
            temp_Area( DayInx1to6(temp2) ) = A2; %LastArea;
            
% % %             N_newLake = N_newLake+1;
% % %             Register_Area_buffer(:,N_newLake) = ...
% % %                 [5; DayInx1to6(temp2); LastArea; temp_Area; ...
% % %                 CorrInx2; zeros(300-LastArea-2,1); 1000+N_merge; 0];
% % %             RegisterMap(CorrInx2) = N_existLake + N_newLake;

            Register_Area = [Register_Area, ...
                [5; DayInx1to6(temp2); A2; temp_Area; ...
                CorrInx2; zeros(300-A2-2,1); 1000+N_merge; 0] ];

% % % %             Register_Area = [Register_Area, ...
% % % %                 [5; DayInx1to6(temp2); LastArea; temp_Area; ...
% % % %                 CorrInx2; zeros(300-LastArea-2,1); 1000+N_merge; 0] ];
            % established left day, examine day index, maximum area, 
            % area record in each day, index of maximum lake
            

            % ---------- Register_Intensity ---------
            temp_Inten = [ZeroArea; ZeroArea; ZeroArea];

            [Darkest, Top5P, Avg] = CalIntensity(temp2, CorrInx2); 
            temp_Inten(DayInx1to6(temp2) ) = Darkest;
            temp_Inten(DayInx1to6(temp2)+N_ChosenImg ) = Top5P;
            temp_Inten(DayInx1to6(temp2)+N_ChosenImg*2 ) = Avg;

            Register_Intensity = [Register_Intensity, temp_Inten];


            temp = size(Register_Area,2);            
            RegisterMap(CorrInx2) = temp; % establish
            
            
            if (SaveTrackImg == 1)
                N_Lake = N_Lake + 1;
%                 Area = length(CorrInx2);
%                 PlotLake(1:3+Area,N_Lake) = ...
%                     [DayInx1to6(temp2); DayInx1to6(temp2); Area; CorrInx2];  
                PlotLake(1:3+A2,N_Lake) = ...
                    [DayInx1to6(temp2); DayInx1to6(temp2); A2; CorrInx2];  
                % start day, end day, area, index (300 with zero padding)
            end
            
            continue;
        end % end of merge lake
        
        RegisterMap(RegisterMap == cc) = 0;
        RegisterMap(CorrInx2) = cc;

        % ---- Register_Area -----        
        
        if (leftDay < 0) % establish the un-established lake right now
            
            StartDayInx = ...
                find( (Register_Area(4:3+N_ChosenImg,cc) > 0), 2,'first');
            
            % area in 1st start day and 2nd start day have done in
            % "InitiateLake"
            if StartDayInx(2) + 1 ~= DayInx1to6(temp2)
                Register_Area(3+StartDayInx(2)+1:DayInx1to6(temp2)-1, cc) = ...
                    -1*Register_Area(3+StartDayInx(2), cc);
            end
            
            if (SaveTrackImg == 1)
                N_Lake = N_Lake + 1;
% %                 Area = length(CorrInx1); % length(CorrInx1);
% %                 PlotLake(1:3+Area,N_Lake) = ...
% %                     [StartDayInx(1); (DayInx1to6(temp2)-1); Area; CorrInx1];  
                PlotLake(1:3+A1,N_Lake) = ...
                    [StartDayInx(1); (DayInx1to6(temp2)-1); A1; CorrInx1];  
%                start day, end day, area, index (300 with zero padding)
            end
                    
        else            
            LastAppear_DayInx = find(Register_Area(4:3+DayInx1to6(temp2)-1,cc), 1,'last');
            if LastAppear_DayInx+1 ~= DayInx1to6(temp2)
                Register_Area(3+LastAppear_DayInx+1:3+DayInx1to6(temp2)-1, cc) ...
                    = -1*Register_Area(3+LastAppear_DayInx,cc);
            end
                        
            if (SaveTrackImg == 1)
                N_Lake = N_Lake + 1;
% %                 Area = length(CorrInx1);
% %                 PlotLake(1:3+Area,N_Lake) = ...
% %                     [LastAppear_DayInx; (DayInx1to6(temp2)-1); Area; CorrInx1];                  
                PlotLake(1:3+A1,N_Lake) = ...
                    [LastAppear_DayInx; (DayInx1to6(temp2)-1); A1; CorrInx1];
%                 start day, end day, area, index (300 with zero padding)
            end
        end
        
        
        if (SaveTrackImg == 1) % plot corresponding lake
            N_Lake = N_Lake + 1;
% %             Area = length(CorrInx2);
% %             PlotLake(1:3+Area,N_Lake) = ...
% %                 [DayInx1to6(temp2); DayInx1to6(temp2); Area; CorrInx2];  
            PlotLake(1:3+A2,N_Lake) = ...
                [DayInx1to6(temp2); DayInx1to6(temp2); A2; CorrInx2];  
%                     start day, end day, area, index (300 with zero padding)                    
        end
            
%         AreaNext = length(CorrInx2);
        Register_Area(1,cc) = 5; % refresh the clear day count
        % it could be keep tracking, or the 1st establish, doesn't matter
        Register_Area(2,cc) = DayInx1to6(temp2); % update examine day
        Register_Area(3+ DayInx1to6(temp2), cc) = A2; %AreaNext; %fill the area found in last appear day

%         if Register_Area(cc,3) < AreaNext
            Register_Area(3,cc) = A2; %AreaNext; % update last appear area
            Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A2,cc) = CorrInx2; % update index of maximum area
%         end
        
            % ---------- Register_Intensity ---------
        temp_Inten = Register_Intensity(:,cc);
                        
        [Darkest, Top5P, Avg] = CalIntensity(temp2, CorrInx2);
        temp_Inten(DayInx1to6(temp2) ) = Darkest;
        temp_Inten(DayInx1to6(temp2)+N_ChosenImg ) = Top5P;
        temp_Inten(DayInx1to6(temp2)+N_ChosenImg*2 ) = Avg;
                
        Register_Intensity(:,cc) = temp_Inten;

        
    else % (IsLake == 0), found no corresponding lake in 6 days
        
        if (leftDay > 0) % have establish             
            
            % find if there are corresponding for the next overlapped region
%             IsLake = 0;
            temp2 = appear3(2); % use next available cluster as standard previous frame            
            ii = 3;

            while (IsLake == 0 && ii<=6 && appear3(ii) ~=0)  
                temp3 = appear3(ii);
                [IsLake, CorrInx2, CorrInx3, A2, A3] = ...
                    IsCorrespondQ_1_2(R_Inx, temp2, temp3);                
                ii = ii+1;
            end

            if (IsLake == 1) % yes, there are corresponding for the next overlapped region ==> still exist
               
                tempInx = RegisterMap(CorrInx3);
                tempInx = tempInx(tempInx>0);
                tempInx = sort(tempInx, 'ascend');
        
                % more than 1 label in the corresponding lake --> merge
                if any(tempInx ~= tempInx(1)) 
                % --- output collided small lakes, no matter established or not

                    N_merge = N_merge+1;
            
                    LL = tempInx(1);
                    % put negative area for ploting later on 
                    % don't put any area on the merged day
                    LastAppear_DayInx = find(Register_Area(3+1:3+DayInx1to6(temp2)-1, LL), 1,'last');

                    if (~isempty(LastAppear_DayInx))
                        if LastAppear_DayInx+1 ~= DayInx1to6(temp2)
                            Register_Area(3+LastAppear_DayInx+1:3+DayInx1to6(temp2)-1, LL) ...
                                = -1*Register_Area(3+LastAppear_DayInx, LL);
                        end
                        if DayInx1to6(temp2)+1 ~= DayInx1to6(temp3)
                            Register_Area(3+DayInx1to6(temp2)+1:3+DayInx1to6(temp3)-1, LL) ...
                                = -1*A2; %length(CorrInx2);
                        end                    
    
                        N_ReportLake = N_ReportLake+1;
                        LakeReport_temp(:,N_ReportLake) = ...
                            [Register_Area(3:3+N_ChosenImg+300-1,LL); N_merge];
                        IntensityReport_temp(:,N_ReportLake) = Register_Intensity(:,LL);

                        if (SaveTrackImg == 1)    
                            N_Lake = N_Lake + 1;
                            Area = Register_Area(3,LL);
                            PlotLake(1:3+Area,N_Lake) = ...
                                [LastAppear_DayInx; (DayInx1to6(temp2)-1); Area; ...
                                Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+Area,LL)];  % use maximum area
        %                     start day, end day, area, index (300 with zero padding)                        
                        end                    
                    end
%                     RegisterMap(RegisterMap == LL) = 0;
                    A = Register_Area(3,LL);
                    tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,LL);
                    RegisterMap(tt(RegisterMap(tt)==LL)) =0;
                    
                    Register_Area(1,LL) = 0;
                    
                    Len = length(tempInx);
                    for uu = 2:1:Len
                        if tempInx(uu) ~= tempInx(uu-1)
                            LL = tempInx(uu);

                            LastAppear_DayInx = find(Register_Area(3+1:3+DayInx1to6(temp2)-1, LL), 1,'last');
                            if (~isempty(LastAppear_DayInx))

                                if LastAppear_DayInx+1 ~= DayInx1to6(temp2)
                                    Register_Area(3+LastAppear_DayInx+1:3+DayInx1to6(temp2)-1, LL) ...
                                        = -1*Register_Area(3+LastAppear_DayInx, LL);
                                end
                                
                                if DayInx1to6(temp2)+1 ~= DayInx1to6(temp3)
                                    Register_Area(3+DayInx1to6(temp2)+1:1:3+DayInx1to6(temp3)-1, LL) ...
                                        = -1*A2; %length(CorrInx2);
                                end                    
                                N_ReportLake = N_ReportLake+1;
                                LakeReport_temp(:,N_ReportLake) = ...
                                    [Register_Area(3:3+N_ChosenImg+300-1,LL); N_merge];
                                IntensityReport_temp(:,N_ReportLake) = Register_Intensity(:,LL);

                                if (SaveTrackImg == 1) 
                                    N_Lake = N_Lake + 1;
                                    Area = Register_Area(3,LL);
                                    PlotLake(1:3+Area,N_Lake) = ...
                                    [LastAppear_DayInx; (DayInx1to6(temp2)-1); Area; ...
                                    Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+Area,LL)];  % use maximum area
            %                     start day, end day, area, index (300 with zero padding)                        
                                end                    
                            end
%                             RegisterMap(RegisterMap == LL) = 0;
                            A = Register_Area(3,LL);
                            tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,LL);
                            RegisterMap(tt(RegisterMap(tt)==LL)) =0;
                            
                            Register_Area(1,LL) = 0;
                        end
                    end
            
                    % ----- establish new lake -------
%                     LastArea = length(CorrInx3);                    
                    temp_Area = ZeroArea;        
                    temp_Area( DayInx1to6(temp3) ) = A3; %LastArea;
                    
% % %                     N_newLake = N_newLake+1;
% % %                     Register_Area_buffer(:,N_newLake) = ...
% % %                         [5; DayInx1to6(temp3); LastArea; temp_Area; ...
% % %                         CorrInx3;zeros(300-LastArea-2,1); 1000+N_merge; 0];
% % % 
% % %                     RegisterMap(CorrInx3) = N_existLake + N_newLake;

                    Register_Area = [Register_Area, ...
                                [5; DayInx1to6(temp3); A3; temp_Area; ...
                                CorrInx3;zeros(300-A3-2,1); 1000+N_merge; 0] ];
% %                     Register_Area = [Register_Area, ...
% %                                 [5; DayInx1to6(temp3); LastArea; temp_Area; ...
% %                                 CorrInx3;zeros(300-LastArea-2,1); 1000+N_merge; 0] ];
                    % established left day, examine day index, maximum area, 
                    % area record in each day, index of maximum lake
                    
                    temp_Inten = [ZeroArea; ZeroArea; ZeroArea];

                    [Darkest, Top5P, Avg] = CalIntensity(temp3, CorrInx3); 
                    temp_Inten(DayInx1to6(temp3) ) = Darkest;
                    temp_Inten(DayInx1to6(temp3)+N_ChosenImg ) = Top5P;
                    temp_Inten(DayInx1to6(temp3)+N_ChosenImg*2 ) = Avg;

                    Register_Intensity = [Register_Intensity, temp_Inten];
        
                    

                    temp = size(Register_Area,2);            
                    RegisterMap(CorrInx3) = temp; % establish

                    if (SaveTrackImg == 1)
                            N_Lake = N_Lake + 1;
%                             Area = length(CorrInx2);
                            PlotLake(1:3+A2,N_Lake) = ...
                                [DayInx1to6(temp2); (DayInx1to6(temp3)-1); A2; CorrInx2];
        %                     start day, end day, area, index (300 with zero padding)                    

                            N_Lake = N_Lake + 1;
%                             Area = length(CorrInx3);
                            PlotLake(1:3+A3,N_Lake) = ...
                                [DayInx1to6(temp3); DayInx1to6(temp3); A3; CorrInx3];
                    end            
                    continue;
                end        
                RegisterMap(RegisterMap == cc) = 0;
               RegisterMap(CorrInx3) = cc;
                              
               % ---- Register_Area -----
               Register_Area(1,cc) = 5; % refresh the clear day count
               Register_Area(2,cc) = DayInx1to6(temp3); % update examine day (still record multiple lakes after it merge)

               LastAppear_DayInx = find(Register_Area(3+1:3+DayInx1to6(temp2)-1,cc), 1,'last');
               if LastAppear_DayInx+1 ~= DayInx1to6(temp2)
                    Register_Area(3+LastAppear_DayInx+1:3+DayInx1to6(temp2)-1, cc) ...
                        = -1*Register_Area(3+LastAppear_DayInx, cc);
               end
                
               if DayInx1to6(temp2)+1 ~= DayInx1to6(temp3)
                   Register_Area(3+DayInx1to6(temp2)+1:1:3+DayInx1to6(temp3)-1, cc) = -1*A2; %length(CorrInx2);
               end                    

            if (SaveTrackImg == 1)
                    N_Lake = N_Lake + 1;
%                     Area = length(CorrInx1);
                    PlotLake(1:3+A1,N_Lake) = ...
                        [LastAppear_DayInx; (DayInx1to6(temp2)-1); A1; CorrInx1];  % use maximum area

                    N_Lake = N_Lake + 1;
%                     Area = length(CorrInx2);
                    PlotLake(1:3+A2,N_Lake) = ...
                        [DayInx1to6(temp2); (DayInx1to6(temp3)-1); A2; CorrInx2];  
%                     start day, end day, area, index (300 with zero padding)                    

                    N_Lake = N_Lake + 1;
%                     Area = length(CorrInx3);
                    PlotLake(1:3+A3,N_Lake) = ...
                        [DayInx1to6(temp3); DayInx1to6(temp3); A3; CorrInx3];
            end
               
               % ---- last appear area of Register_Area
%                AreaNext = length(CorrInx3);
               Register_Area(3,cc) = A3; %AreaNext; % update last appear area
               Register_Area(3+DayInx1to6(temp2), cc) = A2; %length(CorrInx2);
               Register_Area(3+DayInx1to6(temp3), cc) = A3; %AreaNext;
               Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A3, cc) = CorrInx3; % update index of maximum area
               
               

        temp_Inten = Register_Intensity(:,cc);
                        
        [Darkest, Top5P, Avg] = CalIntensity(temp3, CorrInx3);
        temp_Inten(DayInx1to6(temp3) ) = Darkest;
        temp_Inten(DayInx1to6(temp3)+N_ChosenImg ) = Top5P;
        temp_Inten(DayInx1to6(temp3)+N_ChosenImg*2 ) = Avg;
                
        Register_Intensity(:,cc) = temp_Inten;               
                              
               % record last area
% % %                Area2 = length(CorrInx2);
% % %                Register_Area(cc, 3+ DayInx1to6(temp2) ) = Area2; %fill the area found in last appear day
% % % 
% % %                Area3 = length(CorrInx3);
% % %                Register_Area(cc, 3+ DayInx1to6(temp3) ) = Area3; %fill the area found in last appear day
% % % 
% % %                if (Area2 < Area3)
% % %                    AreaNext = Area3;
% % %                    InxA = CorrInx3;
% % %                else
% % %                    AreaNext = Area2;
% % %                    InxA = CorrInx2;
% % %                end
% % % 
% % %                if Register_Area(cc,3) < AreaNext
% % %                    Register_Area(cc,3) = AreaNext; % update maximum area
% % %                    Register_Area(cc,3+N_ChosenImg+1:3+N_ChosenImg+AreaNext) = InxA; % update index of maximum area
% % %                end
               
            else % even no correspoding for next overlapped. count how many miss clear day
                MissClearDay = min(CloudFreeGroup_5(R_Inx));
                leftCount = Register_Area(1,cc) - MissClearDay;

                if (leftCount <= 0) % miss in 5 "clear" days. Disappear. stop record it and report it.
                    temp = Register_Area(3,cc); % maximum area
                    N_ReportLake = N_ReportLake+1;
                    LakeReport_temp(:,N_ReportLake) = ... %Register_Area(3:end,cc);
                        [Register_Area(3:3+N_ChosenImg+temp,cc); zeros(300-temp-2,1); Register_Area(end-1:end,cc)];
%                         [Register_Area(3:3+N_ChosenImg+temp,cc); zeros(300-temp,1)];
                    IntensityReport_temp(:,N_ReportLake) = Register_Intensity(:,cc);
                    
%                     RegisterMap(RegisterMap == cc) = 0;
                    A = Register_Area(3,cc);
                    tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,cc);
                    RegisterMap(tt(RegisterMap(tt)==cc)) =0;
                    
                    Register_Area(1,cc) = 0;
                else
                    Register_Area(1,cc) = leftCount;
                    Register_Area(2,cc) = DayInx1to6(6); % update examine day
                end
            end

        else % have not established, Register_Area(cc,1)<0

            MissClearDay = min(CloudFreeGroup_6(R_Inx));
            leftCount = Register_Area(1,cc) + MissClearDay;

            if (leftCount >= 0) % miss in 5 "clear" days. not a lake. destroy it
%                 RegisterMap(RegisterMap == cc) = 0;
                A = Register_Area(3,cc);
                tt = Register_Area(3+N_ChosenImg+1:3+N_ChosenImg+A,cc);
                RegisterMap(tt(RegisterMap(tt)==cc)) =0;
                
                Register_Area(1,cc) = 0;
            else
                Register_Area(1,cc) = leftCount;
                Register_Area(2,cc) = DayInx1to6(6); % update examine day
            end
        end
    end
end

LakeReport_temp = LakeReport_temp(:,1:N_ReportLake);
IntensityReport_temp = IntensityReport_temp(:,1:N_ReportLake);
% % % Register_Area = [Register_Area, Register_Area_buffer(:,1:N_newLake)];


    % ---- output the tracked lake. when it's not appear, show the previous
    % appear lake --------
if (SaveTrackImg == 1)        

    if (N_Lake>0) 
        EarliestInx = min(PlotLake(1,1:N_Lake)); % start day, end day, area, index (300)
        LatestInx = max(PlotLake(2,1:N_Lake));
        
        for ddInx = EarliestInx:1:LatestInx
            
            temp = find(PlotLake(1,:) <= ddInx & PlotLake(2,:) >= ddInx); % lake need to plot in certain day
            
            tempMap = zeros(1000*500,1);
            Len = length(temp);
            for qq = 1:1:Len
                Inx = temp(qq);
                Area = PlotLake(3,Inx);
                tempMap(PlotLake(3+1:3+Area,Inx)) = 1;
            end

            dd = Register_Area_Day(ddInx);
            tempImg = imread([Output_Dir_temporal, num2str(year), num2str(dd), '__Track.png'], 'PNG');

%             [~,~,l]= size(tempImg);

            tempImg(tempMap == 1) = 255; % 230:ceil(255.*Maxtt1); % previous: red            
            imwrite(uint8(tempImg), [Output_Dir_temporal, num2str(year), num2str(dd), '__Track.png'], 'PNG');

            
% % % %             if  l == 1
% % % %                 tt1 = zeros(1000, 500, 3);
% % % %                 tt1(:,:,1) = tempImg;
% % % %                 tt1(:,:,2) = tempImg;
% % % %                 tt1(:,:,3) = tempImg;
% % % %             else % l == 3
% % % %                 tt1 = tempImg;
% % % %             end
% % % %                     
% % % %             tempInx = (tempMap == 1);
% % % % 
% % % %             tt2 = tt1(:,:,1);
% % % %             tt2(tempInx) = 230; % ceil(255.*Maxtt1); % previous: red
% % % %             tt1(:,:,1) = tt2;
% % % % 
% % % %             tt2 = tt1(:,:,2);
% % % %             tt2(tempInx) = 0;    
% % % %             tt1(:,:,2) = tt2;
% % % %             tt1(:,:,3) = tt2;
% % % % 
% % % %             tt1 = uint8(tt1);
% % % %             imwrite(tt1, [Output_Dir_temporal, num2str(year), num2str(dd), '__Track.png'], 'PNG');
        end

    end
end    


% destroy lake in Register_Area & Register_Intensity
% relabel lake in RegisterMap, get rid of empty one
destroyLabel = find(Register_Area(1,:) == 0); % don't need to sort it
LenDe = length(destroyLabel);

if (LenDe ~=0)
    temp = (Register_Area(1,:) ~= 0);
    Register_Area = Register_Area(:,temp);
    Register_Intensity = Register_Intensity(:,temp);
    
    for ii = 1:1:LenDe-1
        Label_floor = destroyLabel(ii);
        Label_ceil = destroyLabel(ii+1);
        
        RegisterMap(RegisterMap == Label_floor) = 0;
        tempInx = (RegisterMap>Label_floor & RegisterMap<Label_ceil);
        RegisterMap(tempInx) = RegisterMap(tempInx) - ii;                
    end
    
    RegisterMap(RegisterMap == destroyLabel(end)) = 0;
    tempInx = ( RegisterMap > destroyLabel(end) );
    RegisterMap(tempInx) = RegisterMap(tempInx) - LenDe;
end

%%function IM_FullSize = IceMask(RedC)
% % % % plot = 0;
% % % % 
% % % % % kkk = 1;
% % % % lenX = 15; % smaller =  less blur. But it have to larger than lagest found lake
% % % % lenY = 15;
% % % % amp = 10;
% % % % www = 30;
% % % % Thr = 0.2;
% % % % 
% % % % 
% % % % % both are square kernel --> same size when choose 'valid'
% % % % edgeX = amp*[ones(www,lenX), -1*ones(www,lenX)]; % sqaure kernel
% % % % edgeY = (10*[ones(www,lenY), -1*ones(www,lenY)])';
% % % % 
% % % % 
% % % % edgeXMap = abs(conv2(single(RedC), edgeX, 'valid')); % 'valid' or 'same'
% % % % edgeYMap = abs(conv2(single(RedC), edgeY, 'valid'));
% % % % QQQ = edgeXMap.^2 + edgeYMap.^2;
% % % % 
% % % % if (plot)
% % % %     figure(1);
% % % %     subplot(1,4,1); imshow(RedC/max(max(RedC)) ); title('origianl image')
% % % %     subplot(1,4,2); imshow(edgeXMap/max(max(edgeXMap)) ); title('after convert with edge X detector');
% % % %     subplot(1,4,3); imshow(edgeYMap/max(max(edgeYMap)) ); title('after convert with edge Y detector');
% % % %     subplot(1,4,4); imshow(QQQ, [0, max(max(QQQ))] ); title('X^2 + Y^2');
% % % % end
% % % % 
% % % % temp = (QQQ> Thr* max(max(QQQ)));
% % % % % temp = temp(lenY/2+1: end-lenY/2-1, lenX/2+1: end-lenX/2-1);
% % % % 
% % % % if(plot)
% % % %     figure(2); 
% % % %     subplot(1,3,1); imshow(temp);
% % % % end
% % % % 
% % % % [rr,cc] = size(temp);
% % % % IM = zeros(rr,cc);
% % % % edge = zeros(1,rr);
% % % % Mask_Margin = 20;
% % % % 
% % % % for ii = 1:1:rr
% % % %     ttt = find(temp(ii,:),1,'last');
% % % %     if (~isempty(ttt))
% % % %         edge(ii) = ttt;
% % % %         IM(ii, ttt+1+Mask_Margin:end) = 1;
% % % %     else
% % % %         edge(ii) = edge(ii-1);
% % % %         IM(ii, edge(ii)+1+Mask_Margin:end) = 1;
% % % %     end
% % % % end
% % % % 
% % % % temp = IM.*RedC(lenY+1: end-lenY+1, lenX+1: end-lenX+1);
% % % % 
% % % % if(plot)
% % % %     subplot(1,3,2); imshow(IM, [0,1]);
% % % %     subplot(1,3,3); imshow(temp, [0,max(max(temp))]);
% % % % end
% % % % 
% % % % IM_FullSize = zeros(size(RedC));
% % % % IM_FullSize(lenY+1: end-lenY+1, lenX+1: end-lenX+1) = IM;

%% Find lake for each image
function [LabelMap, LakeLookUp_temp] = ...
    FindLake_SingleImage(IM, inx_possibleLake, LakeInxS_Add1, rr,cc)
% mlock
global ii_outside

% ---- setting parameters ----
% ColorMargin = Ave_brightness/8; %<---- or, should use Max/10

% ii_outsideHalf = (ii_outside-1)/2;
% % MinLakeSeed = 2;
% % MaxLakeArea = ii_outside* ii_outside;


% ColorMargin = 0.05; % lake expending: color margin between the average
% value  
% only lower value works for darker (lower contrast) image

% notes: larger ColorMargin = fill more holds, but longer calcualtion time,
% larger lakes (might need have a upper limit of the lake area, expecially
% lighter lake expand more, since it's more close to it's neighbor).

% since the seed map is already done a good job, here I choose a smaller
% ColorMargin, and get rid of any seed which is smaller than MinLakeSeed.

%---- seed map -----
SeedMap = uint8(zeros(rr,cc));
SeedMap(inx_possibleLake) = 1;

%% initial started image

% % % if (ll == 3)
% % %     RedC = double(InpF(:,:,1)); %Yuli: 3 channel
% % % else
% % %     RedC = double(InpF);
% % % end

% % temp = RedC(500:900, 100:500);
% % temp = RedC.*IM;
% % figure(3); imshow(temp, [0,max(max(temp))] ); title('origianl image')
% % 
% % [rr,cc] = size(RedC);
% % temp = RedC .* IM;
% % temp = reshape(temp,[],1);
% % temp(temp==0) = [];
% % figure(1); hist(reshape(temp,[],1), 500);

    
% % % %     figure(1); imshow(RedC, [-0.01, 1]);
% % % %     figure(2); imshow(SeedMap, [0,1]);    
% % % %     title('final "seeds" of detected lakes')
% % % % 
% % % %     figure(1); imshow(RedC(650:900, 200:400), [-0.01, 1]);
% % % % figure(2); imshow(SeedMap(650:900, 200:400), [0,1]);
% % % % 
% % % %  figure(1); imshow(RedC(200:600, 200:500), [-0.01, 1]);
% % % % figure(2); imshow(SeedMap(200:600, 200:500), [0,1]);

% end

%% ---- define cluster, and assign number in each cluster ---
[LabelMap, cluster] = LabelCluster(rr,cc,SeedMap);


% % % % % % % for ii = 2:1:rr
% % % % % % % for jj = 2:1:cc
% % % % % % %     
% % % % % % %     if(SeedMap(ii,jj) == 1)
% % % % % % %         if( (SeedMap(ii-1, jj) == 1) )
% % % % % % %             LabelMap(ii,jj) = LabelMap(ii-1,jj) ;
% % % % % % %         elseif (SeedMap(ii, jj-1) == 1)
% % % % % % %             LabelMap(ii,jj) = LabelMap(ii,jj-1) ;
% % % % % % %         elseif (SeedMap(ii-1, jj-1) == 1)
% % % % % % %             LabelMap(ii,jj) = LabelMap(ii-1,jj-1) ;
% % % % % % %         elseif( (SeedMap(ii-1, jj+1) == 1) && (SeedMap(ii, jj+1) == 1) )
% % % % % % %             LabelMap(ii,jj) = LabelMap(ii-1,jj+1) ;
% % % % % % %         else % no neighbors
% % % % % % %             cluster = cluster + 1; % number cluster
% % % % % % %             LabelMap(ii,jj) = cluster; % assign the cluster label
% % % % % % %             % label is positive integer start from 1. Non-Label = zero
% % % % % % %         end
% % % % % % %     end    
% % % % % % % end
% % % % % % % end


% determine the threshold of shallow lakes
% ------- by the cluster of background of darker center ----
% % % % temp = IM;
% % % % temp(inx_possibleLake) = 0;
% % % % NonLakePixel_Intensity = InpF(temp==1);
% % % % [tempInx, tempCenter] = kmeans(NonLakePixel_Intensity,2);
% % % % 
% % % % if tempCenter(1) < tempCenter(2)
% % % %     DarkerBackground = NonLakePixel_Intensity(tempInx == 1);
% % % %     BackgroundMean = tempCenter(1);
% % % % else
% % % %     DarkerBackground = NonLakePixel_Intensity(tempInx == 2);
% % % %     BackgroundMean = tempCenter(2);
% % % % end
% % % % BackgroundSTD = std(DarkerBackground);
% % % % tttt = 0;
% % % % Max_Lake_MinIntensity = BackgroundMean - (BackgroundSTD * tttt);

% ------ by the fraction of lighter found lake pixels -----
% % % % % % tttt = 10;
% % % % % % PixelIntensity = RedC(inx_possibleLake);
% % % % % % tempMax = max(PixelIntensity);
% % % % % % tempMin = min(PixelIntensity);
% % % % % % Max_Lake_MinIntensity = tempMax - (tempMax - tempMin)/tttt;



% % % % % figure; hist(PixelIntensity, 200);
% % % % % LabelMap_temp = LabelMap;
% % % % % while tttt >0
% % % % %     
% % % % %     for ii = 1:1:cluster
% % % % % %         temp = find(LabelMap_temp==ii);
% % % % %         minTemp = min(InpF(LabelMap_temp==ii)); %sum(InpF(temp))/ length(temp); % darkest pixel, or use 
% % % % %         if minTemp > tempMax - (tempMax - tempMin)/tttt
% % % % %             LabelMap_temp(LabelMap_temp==ii) = 0;
% % % % %         end
% % % % %     end    
% % % % %     LakesAndRawData(InpF, IM, find(LabelMap_temp>0), -0.01)
% % % % % keyboard;
% % % % % end



% % % % core5Map = zeros(rr,cc);
% % % % core5Map(inx_possibleLake_core_5) = 1;







% % tempLabelMap = LabelMap;







% =======================
LakeLookUp_temp = zeros(LakeInxS_Add1,  cluster); 
% look up table for lakes
% area + Lake location index (300)

rrcc = rr*cc;
for ii = 1:1:rrcc
    temp = LabelMap(ii);
    if temp ~=0
        A = LakeLookUp_temp(1, temp)+1; % original area + 1
        if (A<LakeInxS_Add1) % set LakeInxS_Add1-1 as maximum available lake
            LakeLookUp_temp(1, temp) = A;
            LakeLookUp_temp(1+A, temp) = ii;
        else % larger than allowable area, destroy it.
            LakeLookUp_temp(1, temp) = 0;
            LabelMap(LabelMap == temp) = 0;
        end
    end        
end


% % LakeLookUp_temp(1, LakeLookUp_temp(1,:)==1) = 0; % if area==1, get rid of it

% get rid of it if any part of it overlap with cloud mask
temp = LabelMap(IM == 0 & LabelMap>0);
% LakeLookUp_temp(1, temp) = 0; 
LakeLookUp_temp(1, temp) = -LakeLookUp_temp(1, temp); 

% % % % if the lake is too big, get rid of it. It is noise, cloud, or wet ice with high possibility
% % % InxAll = find(LakeLookUp_temp(1, :) >= ii_outside);  
% % % Len = length(InxAll);
% % % for ii = 1:1:Len
% % %     Inx = InxAll(ii);
% % %     A = LakeLookUp_temp(1, Inx); % area
% % %     [tempR, tempC] = ind2sub([rr,cc],LakeLookUp_temp(2:1+A, Inx)); % input index to see the loation in R and C
% % %     if ( (max(tempR) - min(tempR))>= ii_outside ||...
% % %          (max(tempC) - min(tempC))>= ii_outside )
% % %         LakeLookUp_temp(1, Inx) = 0; % area
% % %     end    
% % % end

N_KeepLabel = 0;
for ii = 1:1:cluster

    A = LakeLookUp_temp(1, ii);
    if (A < 0) % overlap with cloud mask
        LabelMap(LakeLookUp_temp(2:1-A, ii)) = 0; % 2:1+(-(A))
        LakeLookUp_temp(1, ii) = 0;
    elseif (A == 1) % if area==1 or 0, get rid of it
        LabelMap(LakeLookUp_temp(2, ii)) = 0; % 2:1+A
        LakeLookUp_temp(1, ii) = 0;
    elseif (A >= ii_outside) % if the lake is too big, get rid of it. It is noise, cloud, or wet ice with high possibility
        [tempR, tempC] = ind2sub([rr,cc],LakeLookUp_temp(2:1+A, ii)); % input index to see the loation in R and C
        if ( (max(tempR) - min(tempR))>= ii_outside ||...
             (max(tempC) - min(tempC))>= ii_outside )
            LabelMap(LakeLookUp_temp(2:1+A, ii)) = 0;
            LakeLookUp_temp(1, ii) = 0;
        else
            N_KeepLabel = N_KeepLabel + 1;
            if N_KeepLabel ~= ii
                LabelMap(LakeLookUp_temp(2:1+A, ii)) = N_KeepLabel;
%                 LakeLookUp_temp(:,N_KeepLabel) = LakeLookUp_temp(:,ii);
            end
        end
    elseif (A>0) % if (A==0), don't count
        N_KeepLabel = N_KeepLabel + 1;
        if N_KeepLabel ~= ii
            LabelMap(LakeLookUp_temp(2:1+A, ii)) = N_KeepLabel;
%             LakeLookUp_temp(:,N_KeepLabel) = LakeLookUp_temp(:,ii);
        end
    end    
end

LakeLookUp_temp = LakeLookUp_temp(:, (LakeLookUp_temp(1, :) > 0));
% LakeLookUp_temp = LakeLookUp_temp(:, 1:N_KeepLabel);



% % % % % % % % % % if (0)
% % % % % % % % % %     
% % % % % % % % % %     
% % % % % % % % % %     
% % % % % % % % % %     
% % % % % % % % % % QQQQ_LookUp = LakeLookUp_temp;
% % % % % % % % % % QQQQ_LabelMap = LabelMap;
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % % ========================
% % % % % % % % % % 
% % % % % % % % % % % point out which label "contain no point" or "overlap with mask"
% % % % % % % % % % % % temp = LabelMap .* (IM==0);
% % % % % % % % % % KickOffLabel = zeros(cluster,1); % the label to be kicked off
% % % % % % % % % % KeepLabel_list = ones(cluster,1); 
% % % % % % % % % % LakeLookUp_temp = zeros(LakeInxS_Add1,  cluster); 
% % % % % % % % % % 
% % % % % % % % % % LabelMap = tempLabelMap;
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % N_KickOff = 0;
% % % % % % % % % % for ii = 1:1:cluster
% % % % % % % % % % % %     if (~any(any(LabelMap == ii))); % no lake is labeled this number or if seed is too small
% % % % % % % % % % % %         KickOffLabel = [KickOffLabel, ii]; 
% % % % % % % % % %     tempKeep = 1;
% % % % % % % % % %     Inx_Cluster_ii = find(LabelMap==ii);
% % % % % % % % % %             
% % % % % % % % % % % % % %     minTemp = min(InpF(Inx_Cluster_ii)); %sum(InpF(temp))/ length(temp); % darkest pixel, or use  % if the lake is too big, get rid of it. It is noise, cloud, or wet ice with hight possibility
% % % % % % % % % % % % % %     if minTemp > Max_Lake_MinIntensity
% % % % % % % % % % % % % % %         LabelMap_temp(LabelMap_temp==ii) = 0;
% % % % % % % % % % % % % %         KickOffLabel = [KickOffLabel, ii];
% % % % % % % % % % % % % %         continue;
% % % % % % % % % % % % % %     end
% % % % % % % % % % 
% % % % % % % % % %     if any(IM(Inx_Cluster_ii) == 0) % get rid of it if any part of it overlap with mask
% % % % % % % % % %         N_KickOff = N_KickOff + 1;
% % % % % % % % % %         KickOffLabel(N_KickOff) = ii;
% % % % % % % % % %         tempKeep = 0;
% % % % % % % % % % % % % % %     elseif ~any(core5Map(Inx_Cluster_ii)) % get rid of it if "no" overlap with inx_possibleLake_core_5
% % % % % % % % % % % % % % %         KickOffLabel = [KickOffLabel, ii];
% % % % % % % % % % %     elseif (length(Inx_Cluster_ii) < MinLakeSeed) % no lake is labeled this number or if seed is too small
% % % % % % % % % %     elseif (isempty(Inx_Cluster_ii) || length(Inx_Cluster_ii) == 1) % no lake is labeled this number
% % % % % % % % % %         N_KickOff = N_KickOff + 1;
% % % % % % % % % %         KickOffLabel(N_KickOff) = ii;
% % % % % % % % % %         tempKeep = 0;
% % % % % % % % % %     else 
% % % % % % % % % %         [tempR, tempC] = ind2sub([rr,cc],Inx_Cluster_ii);
% % % % % % % % % % %         [tempR, tempC] = find(LabelMap == ii);
% % % % % % % % % %         if ( (max(tempR) - min(tempR))>= ii_outside ||...
% % % % % % % % % %              (max(tempC) - min(tempC))>= ii_outside )
% % % % % % % % % %             N_KickOff = N_KickOff + 1;
% % % % % % % % % %             KickOffLabel(N_KickOff) = ii;
% % % % % % % % % %             tempKeep = 0;
% % % % % % % % % % % % % % %         else % get rid of tip of large chunk <------ this part
% % % % % % % % % % % seems not very helpful, but take times
% % % % % % % % % % % % % % %             tempR_ave = floor(mean(tempR));
% % % % % % % % % % % % % % %             tempC_ave = floor(mean(tempC));
% % % % % % % % % % % % % % %             
% % % % % % % % % % % % % % %             % interested neighborhood
% % % % % % % % % % % % % % %             LakeAveIntensity = mean(RedC(LabelMap == ii));
% % % % % % % % % % % % % % %             
% % % % % % % % % % % % % % %             tt_SmallR = tempR_ave-ii_outsideHalf;
% % % % % % % % % % % % % % %             if tt_SmallR<1
% % % % % % % % % % % % % % %                 tt_SmallR = 1;
% % % % % % % % % % % % % % %             end
% % % % % % % % % % % % % % %             tt_LargeR = tempR_ave+ii_outsideHalf;
% % % % % % % % % % % % % % %             if tt_LargeR>rr
% % % % % % % % % % % % % % %                 tt_LargeR = rr;
% % % % % % % % % % % % % % %             end
% % % % % % % % % % % % % % %             tt_SmallC = tempC_ave-ii_outsideHalf;
% % % % % % % % % % % % % % %             if tt_SmallC<1
% % % % % % % % % % % % % % %                 tt_SmallC = 1;
% % % % % % % % % % % % % % %             end
% % % % % % % % % % % % % % %             tt_LargeC = tempC_ave+ii_outsideHalf;
% % % % % % % % % % % % % % %             if tt_LargeC>cc
% % % % % % % % % % % % % % %                 tt_LargeC = cc;
% % % % % % % % % % % % % % %             end
% % % % % % % % % % % % % % %             
% % % % % % % % % % % % % % %             tempMap = zeros(tt_LargeR-tt_SmallR+1, tt_LargeC-tt_SmallC+1);
% % % % % % % % % % % % % % %             temp1 = RedC(tt_SmallR: tt_LargeR,tt_SmallC: tt_LargeC);            
% % % % % % % % % % % % % % %             tempMap(temp1 <= LakeAveIntensity + ColorMargin & ...
% % % % % % % % % % % % % % %                 temp1 >= LakeAveIntensity - ColorMargin) = 1; % after expand
% % % % % % % % % % % % % % %                     
% % % % % % % % % % % % % % %             temp2 = (LabelMap == ii);
% % % % % % % % % % % % % % %             temp1 =  temp2(tt_SmallR: tt_LargeR,tt_SmallC: tt_LargeC);
% % % % % % % % % % % % % % %             tempMap2 = (tempMap == 1 & temp1 == 0); % did expand
% % % % % % % % % % % % % % %             
% % % % % % % % % % % % % % %             if (any(tempMap2(1,:)) || any(tempMap2(end,:)) || ...
% % % % % % % % % % % % % % %                     any(tempMap2(:,1)) || any(tempMap2(:,end)) ) % edge have expand point
% % % % % % % % % % % % % % %                 
% % % % % % % % % % % % % % %                 [tempLabelMap, tempCluster] = LabelCluster( tt_LargeR-tt_SmallR+1, tt_LargeC-tt_SmallC+1, tempMap); 
% % % % % % % % % % % % % % %                 tempLabel = tempLabelMap(ii_outsideHalf+1, ii_outsideHalf+1);
% % % % % % % % % % % % % % %                 
% % % % % % % % % % % % % % %                 [tempR, tempC] = find(tempLabelMap == tempLabel);
% % % % % % % % % % % % % % %                 if ( (max(tempR) - min(tempR))>= ii_outside ||...
% % % % % % % % % % % % % % %                      (max(tempC) - min(tempC))>= ii_outside )
% % % % % % % % % % % % % % %                     KickOffLabel = [KickOffLabel, ii];
% % % % % % % % % % % % % % %                 end
% % % % % % % % % % % % % % %             end
% % % % % % % % % %         end
% % % % % % % % % %     end
% % % % % % % % % % 
% % % % % % % % % %     if (tempKeep == 1)
% % % % % % % % % %         temp = length(Inx_Cluster_ii); % area
% % % % % % % % % %         LakeLookUp_temp(1:1+temp,ii) = [temp; Inx_Cluster_ii]; % take care the "lake look up table" at the same time
% % % % % % % % % %     else % not keep
% % % % % % % % % %         KeepLabel_list(ii) = 0; %tempKeep;
% % % % % % % % % %     end
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % LakeLookUp_temp = LakeLookUp_temp(:, KeepLabel_list==1);
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % % get rid of those labels
% % % % % % % % % % if (N_KickOff ~= 0)    
% % % % % % % % % %     for ii = 1:1:N_KickOff-1
% % % % % % % % % %         Label_floor = KickOffLabel(ii);
% % % % % % % % % %         Label_ceil = KickOffLabel(ii+1);
% % % % % % % % % %         LabelMap(LabelMap == Label_floor) = 0;
% % % % % % % % % %         
% % % % % % % % % %         tempInx = (LabelMap>Label_floor & LabelMap<Label_ceil);
% % % % % % % % % %         LabelMap(tempInx) = LabelMap(tempInx) - ii;
% % % % % % % % % %     end
% % % % % % % % % %     LabelMap(LabelMap == KickOffLabel(N_KickOff)) = 0;
% % % % % % % % % %     tempInx = (LabelMap>KickOffLabel(N_KickOff) );
% % % % % % % % % %     LabelMap(tempInx) = LabelMap(tempInx) - N_KickOff;
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % % ====================
% % % % % % % % % % 
% % % % % % % % % % if size(QQQQ_LookUp) == size(LakeLookUp_temp)
% % % % % % % % % %     ;    
% % % % % % % % % % else
% % % % % % % % % %     keyboard;
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % % if (QQQQ_LookUp ~= LakeLookUp_temp) % this statement only true when EVERY element of each are un-equal
% % % % % % % % % % if (QQQQ_LookUp == LakeLookUp_temp)
% % % % % % % % % %     ;
% % % % % % % % % % else
% % % % % % % % % %     keyboard;
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % if (size(QQQQ_LabelMap) == size(LabelMap) )
% % % % % % % % % %     ;
% % % % % % % % % % else
% % % % % % % % % %     keyboard;
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % if (QQQQ_LabelMap == LabelMap)
% % % % % % % % % %     ;
% % % % % % % % % % else
% % % % % % % % % %     keyboard;
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % 
% % % % % % % % % % end
% % LakesAndRawData(InpF, IM, find(LabelMap>0), -0.01)


% % cluster = max(max(LabelMap));

% % % % figure; imshow(IM, [0,1]); title('cloud mask');
% % % % tempC = LabelMap/cluster;
% % % % figure; imshow(tempC); title('Label map'); % afer assign the number of
% % % % % each cluster

return;

% Have make the lake big. don't expand it. shallow lakes would be more
% fluctuance, but shallow lakes is not what we concern

%% calculate average reflectance of each lakes ------

% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % if (ll == 3)
% % % % % % % % % % % % % % % % % % % %     BlueC = double(InpF(:,:,3)); %Yuli: 3rd /blue channel
% % % % % % % % % % % % % % % % % % % % else
% % % % % % % % % % % % % % % % % % % %     BlueC = double(InpF);
% % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % Ave = zeros(1,cluster); % index: lake label; value: mean value
% % % % % % % % % % % % % % % % % % % % for ii = 1:1:cluster
% % % % % % % % % % % % % % % % % % % %     Ave(ii) = mean(BlueC(LabelMap == ii));
% % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % for ii = 1:1:cluster
% % % % % % % % % % % % % % % % % % % % % % % % % for jj = ii+1:1:cluster
% % % % % % % % % % % % % % % % % % % % % % % % %     if (Ave(ii) == Ave(jj))
% % % % % % % % % % % % % % % % % % % % % % % % %         fprintf(['Repeated mean value: ', num2str(ii),' & ', num2str(jj)] );
% % % % % % % % % % % % % % % % % % % % % % % % % % %         keyboard;
% % % % % % % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % ------ remove no-lake dots on LabelMap -------
% % % % % % % % % % % % % % % % % % % % % % % % % NotLakeC = find(Ave < ThrAve); % not lakes are with less blue in them
% % % % % % % % % % % % % % % % % % % % % % % % % LakeC = find(Ave >= ThrAve); % lakes are with more blue in them
% % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % temp = LabelMap;
% % % % % % % % % % % % % % % % % % % % % % % % % for ii = 1:1:length(NotLakeC)
% % % % % % % % % % % % % % % % % % % % % % % % %     temp(temp==NotLakeC(ii)) = 0;
% % % % % % % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % LabelMap = temp;
% % % % % % % % % % % % % % % % % % % % % % % % % tempC = LabelMap/max(max(LabelMap));
% % % % % % % % % % % % % % % % % % % % % % % % % figure; imshow(tempC);
% % % % % % % % % % % % % % % % % % % % % % % % % title('remove non-lake seeds by blue channel')
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % ----- for each cluster, replace by it's average value ---
% % % % % % % % % % % % % % % % % % % % MeanValMap = zeros(rr,cc); % store the average
% % % % % % % % % % % % % % % % % % % % Inx = find(LabelMap>0);
% % % % % % % % % % % % % % % % % % % % MeanValMap(Inx) = Ave(LabelMap(Inx)); 
% % % % % % % % % % % % % % % % % % % % % MeanValMap: only have mean value in the labeled points. Otherwise, zero
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % %% ---- For each lake cluster, expend it ---
% % % % % % % % % % % % % % % % % % % % % for speed up algorithm, could try to find the individual lake point, and
% % % % % % % % % % % % % % % % % % % % % find the one with un-labeled lake
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % flag = 1;
% % % % % % % % % % % % % % % % % % % % ALL_Zero = zeros(rr,cc);
% % % % % % % % % % % % % % % % % % % % L_delete = ones(1,cluster); % Label: after deleted, 0
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % % while (flag >0) % expend in 8 direction (2D images)
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     Center = MeanValMap(2:end-1, 2:end-1);
% % % % % % % % % % % % % % % % % % % %     Center_L = LabelMap(2:end-1, 2:end-1);
% % % % % % % % % % % % % % % % % % % %     flag = 0;
% % % % % % % % % % % % % % % % % % % %     Mean_expand = ALL_Zero;
% % % % % % % % % % % % % % % % % % % %     Label_expand = ALL_Zero;
% % % % % % % % % % % % % % % % % % % %     Mean_overlap = ALL_Zero;
% % % % % % % % % % % % % % % % % % % %     Label_overlap = ALL_Zero;
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % %     for ii = -1:1:1
% % % % % % % % % % % % % % % % % % % %     for jj = -1:1:1
% % % % % % % % % % % % % % % % % % % %       if (ii==0 && jj ==0) % skip center, which is the original point
% % % % % % % % % % % % % % % % % % % %           % origianl if (ii~=0 && jj ~=0) go---!
% % % % % % % % % % % % % % % % % % % %       else
% % % % % % % % % % % % % % % % % % % %         temp = ALL_Zero;
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % %         % use LabelMap. MeanValMap might have multiple same mean values
% % % % % % % % % % % % % % % % % % % %         temp(2+ii :end-1+ii, 2+jj: end-1+jj) = Center_L; 
% % % % % % % % % % % % % % % % % % % %         shiftM = temp - LabelMap; % Label shift map - origianl Label map
% % % % % % % % % % % % % % % % % % % %         inx_expand = (shiftM == temp & temp ~=0); % expand pixel
% % % % % % % % % % % % % % % % % % % %         inx_overlap = (temp~=0 & LabelMap~=0 & shiftM ~= 0); % overlap pixels
% % % % % % % % % % % % % % % % % % % %         Label_expand(inx_expand) = temp(inx_expand);
% % % % % % % % % % % % % % % % % % % %         Label_overlap(inx_overlap) = temp(inx_overlap);    
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % %         temp = ALL_Zero;
% % % % % % % % % % % % % % % % % % % %         temp(2+ii :end-1+ii, 2+jj: end-1+jj) = Center; 
% % % % % % % % % % % % % % % % % % % %         Mean_expand(inx_expand) = temp(inx_expand);
% % % % % % % % % % % % % % % % % % % %         Mean_overlap(inx_overlap) = temp(inx_overlap);
% % % % % % % % % % % % % % % % % % % %         
% % % % % % % % % % % % % % % % % % % %       end
% % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % %     end  
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     % find the index of pixel for expanding (won't affect overlapped pixels)
% % % % % % % % % % % % % % % % % % % %     tt3 = abs(Mean_expand-BlueC).* (Mean_expand>0); % difference
% % % % % % % % % % % % % % % % % % % %     inx = find(tt3 < ColorMargin & tt3 > 0);
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % %         
% % % % % % % % % % % % % % % % % % % %     % if inx overlap with cloud (expand into Cloud Mask), 
% % % % % % % % % % % % % % % % % % % %     % delete this lake, and don't expand it
% % % % % % % % % % % % % % % % % % % %     inx_expandCM = find(IM(inx)==0);
% % % % % % % % % % % % % % % % % % % %     if (~isempty(inx_expandCM) )
% % % % % % % % % % % % % % % % % % % %         for ii = 1:1:length(inx_expandCM)
% % % % % % % % % % % % % % % % % % % %             inx_tt = inx(inx_expandCM(ii));
% % % % % % % % % % % % % % % % % % % %             L1 = Label_expand(inx_tt);
% % % % % % % % % % % % % % % % % % % %             if (L_delete(L1) ~= 0)
% % % % % % % % % % % % % % % % % % % %                 L_delete(L1) = 0;
% % % % % % % % % % % % % % % % % % % %                 MeanValMap(LabelMap == L1) = 0;
% % % % % % % % % % % % % % % % % % % %                 LabelMap(LabelMap == L1) = 0;           
% % % % % % % % % % % % % % % % % % % %             end
% % % % % % % % % % % % % % % % % % % %         end
% % % % % % % % % % % % % % % % % % % %         inx(inx_expandCM) = [];
% % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     % put the expand point in to Mean Value Map & Label Map
% % % % % % % % % % % % % % % % % % % %     if (~ isempty(inx))
% % % % % % % % % % % % % % % % % % % %         MeanValMap(inx) = Mean_expand(inx);% average value of each lake
% % % % % % % % % % % % % % % % % % % %         LabelMap(inx) = Label_expand(inx);
% % % % % % % % % % % % % % % % % % % %         flag = 1;
% % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     % merge / delete encountering lakes
% % % % % % % % % % % % % % % % % % % %     inx = find(Label_overlap>0);  
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     while (~isempty(inx))
% % % % % % % % % % % % % % % % % % % %           inx_tt = inx(1);
% % % % % % % % % % % % % % % % % % % %           L1 = Label_overlap(inx_tt);
% % % % % % % % % % % % % % % % % % % %           L2 = LabelMap(inx_tt); % LabelMap change after decide Label_overlap
% % % % % % % % % % % % % % % % % % % %           
% % % % % % % % % % % % % % % % % % % %           % LabelMap might change. Make sure overlap labels are not deleted
% % % % % % % % % % % % % % % % % % % %           % and labeL in the LabelMap are still there.                       
% % % % % % % % % % % % % % % % % % % %           if (L_delete(L1) ~= 0 && L2 ~= 0)
% % % % % % % % % % % % % % % % % % % %                 
% % % % % % % % % % % % % % % % % % % %                 tt3 = abs(Mean_overlap(inx_tt)-MeanValMap(inx_tt)); % difference
% % % % % % % % % % % % % % % % % % % %                 if ( tt3 < ColorMargin ) % merge L1 & L2 --> L2
% % % % % % % % % % % % % % % % % % % %                     L_delete(L1) = 0;
% % % % % % % % % % % % % % % % % % % %                     MeanValMap(LabelMap == L1) = (Ave(L2)+Ave(L1))/2;
% % % % % % % % % % % % % % % % % % % %                     MeanValMap(LabelMap == L2) = (Ave(L2)+Ave(L1))/2;
% % % % % % % % % % % % % % % % % % % %                     LabelMap(LabelMap == L1) = L2;
% % % % % % % % % % % % % % % % % % % %                 else % delete both
% % % % % % % % % % % % % % % % % % % %                     L_delete(L1) = 0;
% % % % % % % % % % % % % % % % % % % %                     L_delete(L2) = 0;
% % % % % % % % % % % % % % % % % % % %                     
% % % % % % % % % % % % % % % % % % % %                     MeanValMap(LabelMap == L1) = 0;
% % % % % % % % % % % % % % % % % % % %                     MeanValMap(LabelMap == L2) = 0;
% % % % % % % % % % % % % % % % % % % %                     LabelMap(LabelMap == L1) = 0;
% % % % % % % % % % % % % % % % % % % %                     LabelMap(LabelMap == L2) = 0;
% % % % % % % % % % % % % % % % % % % %                 end
% % % % % % % % % % % % % % % % % % % %                                 
% % % % % % % % % % % % % % % % % % % %           end % currently, don't do any thing if one of label is not exist
% % % % % % % % % % % % % % % % % % % %               % anymore. Wait for next expanding.
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % %           % After merge, don't consider this pair (and it's 
% % % % % % % % % % % % % % % % % % % %           % corresponding pair) in the overlap map anymore
% % % % % % % % % % % % % % % % % % % %           Mean_overlap(Label_overlap == L1 & LabelMap== L2) = 0;
% % % % % % % % % % % % % % % % % % % %           Mean_overlap(Label_overlap == L2 & LabelMap== L1) = 0;
% % % % % % % % % % % % % % % % % % % %           Label_overlap(Label_overlap == L1 & LabelMap== L2) = 0;
% % % % % % % % % % % % % % % % % % % %           Label_overlap(Label_overlap == L2 & LabelMap== L1) = 0;
% % % % % % % % % % % % % % % % % % % %       
% % % % % % % % % % % % % % % % % % % %           inx = find(Label_overlap>0);          
% % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %     % --- when lake expand too much, delete it ----
% % % % % % % % % % % % % % % % % % % %     for ii = 1:1:cluster
% % % % % % % % % % % % % % % % % % % %         if (sum(sum(LabelMap == ii)) >= MaxLakeArea)
% % % % % % % % % % % % % % % % % % % %             L_delete(ii) = 0;
% % % % % % % % % % % % % % % % % % % %             MeanValMap(LabelMap == ii) = 0;
% % % % % % % % % % % % % % % % % % % %             LabelMap(LabelMap == ii) = 0;
% % % % % % % % % % % % % % % % % % % %         end
% % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % %         
% % % % % % % % % % % % % % % % % % % % % % % % % % % %     [tempR, tempC] = ind2sub([rr,cc],inxAll);
% % % % % % % % % % % % % % % % % % % % % % % %     figure(39); imshow(LabelMap/max(max(LabelMap)));
% % % % % % % % % % % % % % % % % % % % % % % %     title('expended LabelMap');
% % % % % % % % % % % % % % % % % % % % % % % %     figure(40); imshow(MeanValMap/max(max(MeanValMap)));
% % % % % % % % % % % % % % % % % % % % % % % %     title('expended MeanValMap');
% % % % % % % % % % % % % % % % % % % % % % % %     keyboard;
% % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % tempC = MeanValMap/max(max(MeanValMap));
% % % % % % % % % % % % % % % % % % % % % % % figure; imshow(tempC);
% % % % % % % % % % % % % % % % % % % % % % % title('Final Result: after expending the lake area');
% % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % 


%% define the label of final found lakes, and count the area (in pixel)
% % % % % % for ii = 1:1:cluster
% % % % % %     if (L_delete(ii) == 1) % label exist
% % % % % %         Inx = find(LabelMap == ii);
% % % % % %         LakeLookUp_temp(ii) = length(Inx);
% % % % % %         Ave(ii) = MeanValMap(Inx(1));
% % % % % %     else % label is not there
% % % % % %         LakeLookUp_temp(ii) = 0;
% % % % % %         Ave(ii) = 0;
% % % % % %     end
% % % % % % end
% % % % % % % % % % % % % % 
% % % % % % % % % % % % % % tempC = LabelMap/max(max(LabelMap));
% % % % % % % % % % % % % % % % figure; imshow(tempC); % afer assign the number of each cluster
function [LabelMap, cluster] = LabelCluster(rr,cc,SeedMap)
% SeedMap have to be at least uint8 (addable), can't be binary (only 0 or 1
% value in the map)

% mlock

% assign the number
cluster = 0;
LabelMap = zeros(rr,cc); % assign label of cluster points

for ii = 1:1:rr-1
for jj = 1:1:cc-1
    
% % %     if (ii == 642 && jj == 227) % corner of lake 38
% % %         keyboard;
% % %     end
    
    if(SeedMap(ii,jj) == 1) % current point have NOT being assigned
        cluster = cluster + 1; % number of cluster
        LabelMap(ii,jj) = cluster; % assign the cluster label
            % label is positive integer start from 1. Non-Label = zero
        SeedMap(ii,jj) = 2;
        
        if (SeedMap(ii, jj+1) == 1) % neighbor have NOT being assigned
            LabelMap(ii,jj+1) = cluster;
            SeedMap(ii,jj+1) = 2;
        elseif (SeedMap(ii, jj+1) == 2) % neighbor have being assigned
            LabelMap(ii,jj) = LabelMap(ii,jj+1); % use previous assigned value
        end
        
        temp = LabelMap(ii,jj); % LabelMap(ii,jj) might change
        if (SeedMap(ii+1, jj) == 1)
            LabelMap(ii+1,jj) = temp;
            SeedMap(ii+1,jj) = 2;
        elseif (SeedMap(ii+1, jj) == 2) % neighbor in next row have being assigned
            LabelMap(ii,jj) = LabelMap(ii+1,jj);
% %             fprintf('   this part should never being used\n');
% %             keyboard;
        end
        
        temp = LabelMap(ii,jj); % LabelMap(ii,jj) might change
        if (SeedMap(ii+1, jj+1) == 1)
            LabelMap(ii+1,jj+1) = temp;
            SeedMap(ii+1,jj+1) = 2;
        elseif (SeedMap(ii+1, jj+1) == 2) % neighbor in next row have being assigned
            LabelMap(ii,jj) = LabelMap(ii+1,jj+1);
            fprintf('   this part should never being used\n');
            keyboard;
        end
        
        if(jj~=1) % 45 degree diagonal
            temp = LabelMap(ii,jj); % LabelMap(ii,jj) might change
            if (SeedMap(ii+1, jj-1) == 1)
                LabelMap(ii+1,jj-1) = temp;
                SeedMap(ii+1,jj-1) = 2;
            elseif (SeedMap(ii+1, jj-1) == 2) % neighbor in next row have being assigned
                LabelMap(ii,jj) = LabelMap(ii+1,jj-1);
            end
        end
        
% %         elseif (SeedMap(ii-1, jj-1) == 1)
% %             LabelMap(ii,jj) = LabelMap(ii-1,jj-1) ;
% %         elseif( (SeedMap(ii-1, jj+1) == 1) && (SeedMap(ii, jj+1) == 1) )
% %             LabelMap(ii,jj) = LabelMap(ii-1,jj+1) ;

    elseif(SeedMap(ii,jj) == 2) % current point have being assigned
        temp = LabelMap(ii,jj);
        if (SeedMap(ii, jj+1) == 1) 
            LabelMap(ii,jj+1) = temp;
            SeedMap(ii,jj+1) = 2;
        elseif (SeedMap(ii, jj+1) == 2)
            if (temp ~= LabelMap(ii,jj+1));
                temp1 = LabelMap(ii,jj+1);
                LabelMap(LabelMap == temp) = temp1;
            end
        end
        
        temp = LabelMap(ii,jj); % LabelMap(ii,jj) might change
        if (SeedMap(ii+1,jj) == 1)
            LabelMap(ii+1,jj) = temp;
            SeedMap(ii+1,jj) = 2;
        elseif (SeedMap(ii+1, jj) == 2)% neighbor in next row have being assigned
% %             fprintf('   this part should never being used\n');
% %             keyboard;
            if (temp ~= LabelMap(ii+1,jj)); % if previous assign different label
                temp1 = LabelMap(ii+1,jj);
                LabelMap(LabelMap == temp) = temp1;
            end
        end

        % -45 degree diagonal
        temp = LabelMap(ii,jj); % LabelMap(ii,jj) might change
        if (SeedMap(ii+1, jj+1) == 1)
            LabelMap(ii+1,jj+1) = temp;
            SeedMap(ii+1,jj+1) = 2;
        elseif (SeedMap(ii+1, jj+1) == 2)% neighbor in next row have being assigned
            fprintf('   this part should never being used\n');
            keyboard;
            if (temp ~= LabelMap(ii+1,jj+1)); % if previous assign different label
                temp1 = LabelMap(ii+1,jj+1);
                LabelMap(LabelMap == temp) = temp1;
            end
        end

        % 45 degree diagonal
        if(jj~=1) 
            temp = LabelMap(ii,jj); % LabelMap(ii,jj) might change
            if (SeedMap(ii+1, jj-1) == 1)
                LabelMap(ii+1,jj-1) = temp;
                SeedMap(ii+1,jj-1) = 2;
            elseif (SeedMap(ii+1, jj-1) == 2) % neighbor in next row have being assigned
                if (temp ~= LabelMap(ii+1,jj-1)); % if previous assign different label
                    temp1 = LabelMap(ii+1,jj-1);
                    LabelMap(LabelMap == temp) = temp1;
                end
            end
        end
        
    end
end
end

% detect Lake Seed of each image
function [inx_possibleLake, message, TopBright5P] = SingleImg_Lake_Seed...
    (data_noCM, Mask_noRock, N_Bin, N_AvePoint, N_AvePoint_Deri, ...
     AlmostZero_1stDeri)

% mlock
global DotK_core_1 DotK_outside_1

% % PlotFigure = 0; % Yuli:KEEP
message = '';
% ii_core = 1; % odd number 3,5,7,etc. make sure even lines

TopBright5P = -1;
% tttt = 1;
inx_possibleLake = [];
% inx_possibleLake_core_1 = [];
% inx_possibleLake_core_5 = [];

for tttt = 1:1:2 %3
    % 1: 1x1 core, initalize lake mask; 
    % 2: 1x1 core, take lake mask into account
    % 3: 5x5 core, take lake mask into account <---- don't use this, too
    % many small lakes and lake in the dark area are not being detected

% % % % if (tttt == 3)    
% % % %     inx_possibleLake_core_1 = inx_possibleLake;
% % % %     ii_core = 3;
% % % % end

% ----- mechanisem: dot kernel + threshold -----
% if maximum lake is about 3km x 3km (12 pixel * 12 pixel)
% core need to be cover the size at least up to this size
% and core size is about (0.5*KernelSize)^2
%
% concatenate the result of sveral different size of kernels

% ----- define core / outside kernel ------
C_core = conv2(data_noCM, DotK_core_1, 'same'); % when core larger than 1 pixel, should consider Mask
C_core = C_core./sum(sum(DotK_core_1)); 
    
% %     figure(2); imshow(data_noCM_ch1.*Mask_noRock, [NotSignal, 0.8]); 
% %     title(['ch1, DD: ', num2str(DD)]);

%         NotNormalHist_Thr = 0.14;
% % kkk = 1;
% % while (kkk == 1)    
    %  for LakeValueThr = 0.0:0.02:0.4
    
    Mask_noLake = Mask_noRock;
    Mask_noLake(inx_possibleLake) = 0;
    
    C_outside_weight = conv2(Mask_noLake, DotK_outside_1, 'same');
    C_outside_value = conv2(data_noCM.*Mask_noLake, DotK_outside_1, 'same');    
% %     C_outside_weight = conv2(Mask_noRock, DotK_outside, 'same');
% %     C_outside_value = conv2(data_noCM.*Mask_noRock, DotK_outside, 'same');    
    C_outside = C_outside_value./C_outside_weight;
    QQQQ = (C_outside - C_core); % no normalized
    QQQQ_1D = QQQQ(Mask_noRock == 1);

        
%---- test: Otsu's grey threshold ----
% % % % tic
% % % % level = graythresh(QQQQ_1D(QQQQ_1D >= 0));
% % % % toc
% % % % inx_possibleLake = find(Mask_noRock == 1 & QQQQ >= level);
% % % %         figure(2); imshow(data_noCM.*Mask_noRock, [NotSignal, 0.9]);    
% % % %         title('origianl image');
% % % % 
% % % %     if (~isempty(inx_possibleLake))
% % % %         figure(3)
% % % %         tt1 = double(data_noCM);
% % % %         temp = zeros([size(tt1),3]);
% % % % 
% % % %         tt2 = tt1;
% % % %         tt2(inx_possibleLake) = 1; %255; % red
% % % %         tt2(Mask_noRock == 0) = 0;
% % % %         temp(:,:,1) = tt2;
% % % % 
% % % %         tt2 = tt1;
% % % %         tt2(inx_possibleLake) = 0;    
% % % %         tt2(Mask_noRock == 0) = 0;
% % % %         temp(:,:,2) = tt2;
% % % %         temp(:,:,3) = tt2;    
% % % % 
% % % %         figure(3); imshow(temp, [NotSignal, 1]);
% % % % %         title(['Seed: NotNormal_Thr=', num2str(NotNormalHist_Thr)]);
% % % %     end



        %============ automatic setting threshold by feature historgram
        %(no normalized one) =========
% % % % % Ave_element_each_Bin = length(QQQQ_1D)/N_Bin;
% % % % % fprintf(['total / N_Bin = ', num2str(Ave_element_each_Bin), '\n'] );

        % --- define Bin ---
        BinSize = ( max(QQQQ_1D)-min(QQQQ_1D) )/N_Bin;
        N_LeftBin = -1* (floor(min(QQQQ_1D)/BinSize));
        N_RightBin = ceil(max(QQQQ_1D)/BinSize);
        BinCenter = -1*N_LeftBin + 1:1:N_RightBin;
        BinCenter = (BinCenter- 1/2) .*  BinSize;
        BinCount = hist(QQQQ_1D, BinCenter);
        RightBinCenter = BinCenter(N_LeftBin+1:end);

        % --- try the ksdensity ----
% % % % % % %         xi = [-0.1:0.01:0.4];
% % % % % % %     [temp] = ksdensity(QQQQ_1D, xi);
% % % % % % %     figure(500); plot(xi,temp);
%     axis([min(xi), max(xi), 0, 1]);
% %     temp = temp(1:end-1)-temp(2:end);
% %     otherThr = find((temp < AlmostZero_1stDeri), 1,'first');
        
        % ===== observe standard deviation =====
        Hist_gt_0 = QQQQ_1D(QQQQ_1D >= 0);
        Hist_gt_0_2side = [-1*Hist_gt_0; Hist_gt_0];
        Right_std = std(Hist_gt_0_2side);

        Hist_lt_0 = QQQQ_1D(QQQQ_1D <= 0);
        Hist_lt_0_2side = [Hist_lt_0; -1*Hist_lt_0];
        Left_std = std(Hist_lt_0_2side);
        
        % ----- Use STD to see which types (1) no lakes (2) with lakes ----
        if (Right_std/Left_std < 1.1)
            message = 'RightDivideLeftStd_lt1.1'; %'Right std/ left std < 1.1, assume no lakes';
            return;
        end
        
        % --- only use the bin with element in it ----
    %     BinCount(1:N_LeftBin); % left histogram
        RightHist = BinCount(N_LeftBin+1:end); % right histogram
        RightHist_gt0_inx = find(RightHist > 0); % find bins which at least have one element
        RightHist_gt0 = RightHist(RightHist > 0);
        
        % ==== moving average of historgram, 1st deri. & 2nd deri. =====
        % --- find the moving average of histogram, calculate the 1st derivitive
        temp = (N_AvePoint-1)/2;
    %     RightHist_1stDeri_Ave5 = RightHist_1stDeri(temp+1+temp:end-temp+temp);    
        RightHist_gt0_Ave = RightHist_gt0(N_AvePoint:end);    
        for jj = -temp:1:temp-1
            RightHist_gt0_Ave = RightHist_gt0_Ave + RightHist_gt0(temp+1+jj:end-temp+jj);
        end
        RightHist_gt0_Ave = RightHist_gt0_Ave./N_AvePoint;  
        RightHist_1stDeri = RightHist_gt0_Ave(1:end-1) - RightHist_gt0_Ave(2:end);  
% %         RightHist_2ndDeri = RightHist_1stDeri(1:end-1) - RightHist_1stDeri(2:end);  % hould use 2nd derivitive = 0 (upper contour and straight line)

        % ----- calcualte moving average of 1st derivitive ---    
        temp = (N_AvePoint_Deri-1)/2;
    %     RightHist_1stDeri_Ave5 = RightHist_1stDeri(temp+1+temp:end-temp+temp);    
        RightHist_1stDeri_Ave = RightHist_1stDeri(N_AvePoint_Deri:end);    
        for jj = -temp:1:temp-1
            RightHist_1stDeri_Ave = RightHist_1stDeri_Ave + RightHist_1stDeri(temp+1+jj:end-temp+jj);
        end
        RightHist_1stDeri_Ave = RightHist_1stDeri_Ave./N_AvePoint_Deri;     

% %         % ----- calcualte moving average of 2nd derivitive ---    
% %         temp = (N_AvePoint_Deri-1)/2;
% %     %     RightHist_1stDeri_Ave5 = RightHist_1stDeri(temp+1+temp:end-temp+temp);    
% %         RightHist_2ndDeri_Ave = RightHist_2ndDeri(N_AvePoint_Deri:end);    
% %         for jj = -temp:1:temp-1
% %             RightHist_2ndDeri_Ave = RightHist_2ndDeri_Ave + RightHist_2ndDeri(temp+1+jj:end-temp+jj);
% %         end
% %         RightHist_2ndDeri_Ave = RightHist_2ndDeri_Ave./N_AvePoint_Deri;     

        % ========= find the desired threshold =====
        % --- when 1st derivitive < AlmostZero_1stDeri----
        HistThr_inx = find((RightHist_1stDeri_Ave < AlmostZero_1stDeri), 1,'first');

        % --- when 1st derivitive < Small_1stDeri & 2nd derivite < AlmostZero_2ndDeri ----
        % use the part when 1st deri. is small and 2nd deri. is almost
        % zero.
% % % %         HistThr_inx = find( ...
% % % %             ((RightHist_1stDeri_Ave(1:end-1) < Small_1stDeri) & (RightHist_2ndDeri_Ave < AlmostZero_2ndDeri) ), ...
% % % %             1,'first'); % make sure two vector have to be the same length
                

    % %     min_HowManyStd = -1* min(QQQQ_1D)/Left_std;
    % %     max_HowManyStd = max(QQQQ_1D)/Left_std;

    
    
    
%---------------- test: if I could find gray spots in contrast histogrm ---
% % % % % EEE = sort(Hist_gt_0, 'descend');
% % % % % TopPoint5P = EEE(ceil(length(EEE) * 0.005) );
% % % % % TopPoint1P = EEE(ceil(length(EEE) * 0.001) );
% % % % %     
% % % % % 
% % % % %         % ---- plot histogram (averaged one) -----
% % % % %         figure(2); subplot(2,1,1); 
% % % % %         hist(QQQQ_1D, BinCenter); hold on;
% % % % %         temp = (N_AvePoint-1)/2;
% % % % %         plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp)) , ...
% % % % %             RightHist_gt0_Ave, 'r-');
% % % % %         hold off;
% % % % % 
% % % % % title(['top 0.5%: ', num2str(TopPoint5P), ', top 0.1%: ', num2str(TopPoint1P), ', Rstd: ', num2str(Right_std), ', Lstd: ', num2str(Left_std)]);          
% % % % %         
% % % % %         % --- plot detail view of histogrm ----
% % % % %         figure(2); subplot(2,1,2); 
% % % % %         hist(QQQQ_1D, BinCenter); hold on;
% % % % %         temp = (N_AvePoint-1)/2;
% % % % %         RightBinCenter = BinCenter(N_LeftBin+1:end);
% % % % %         plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp)) , ...
% % % % %             RightHist_gt0_Ave, 'r-');
% % % % %         hold off;
% % % % %         axis([min(QQQQ_1D), max(QQQQ_1D), 0, 30]);
% % % % % 
% % % % % title(['top 0.5%/Lstd: ', num2str(TopPoint5P/Left_std), ', top 0.1%/Lstd: ', num2str(TopPoint1P/Left_std), ...
% % % % %     ', Rstd/Lstd: ', num2str(Right_std/Left_std), ...
% % % % %     'top 0.5%/Rstd: ', num2str(TopPoint5P/Right_std), ', top 0.1%/Rstd: ', num2str(TopPoint1P/Right_std),] );
% % % % % 
% % % % % keyboard;        
% ---------------------
    
    if ( isempty(HistThr_inx) )
        message = ['No1stDeriEqualTo',num2str(AlmostZero_1stDeri)]; %['No 1st deritive is equal to ',num2str(AlmostZero_1stDeri)];
        return;
    else    
        % -------- area below current threshold ------------------
        temp = (N_AvePoint-1)/2 + (N_AvePoint_Deri-1)/2;
        NotNormalHist_Thr = RightBinCenter(RightHist_gt0_inx(temp+HistThr_inx));
        
        inx_possibleLake = find(Mask_noRock == 1 & QQQQ >= NotNormalHist_Thr);
        % inx_possibleLake = find((data_noCM <LakeValueThr) & (Mask_noRock == 1));
        %     inx_possibleLake = (QQQQ_1 > possibleThr);        

        if tttt > 1
            IceSheetIntensity = data_noCM(Mask_noRock == 1 & QQQQ < NotNormalHist_Thr); %)(inx_possibleIceSheet);    
            temp = sort(IceSheetIntensity, 'descend');
            TopBright5P = temp(ceil(length(temp) * 0.05) );
        end
        
%----------- test: if we could find gray spots in intensity histogrm ---        
% % % % % if tttt == 1        
% % % % %     SpotIntensity = data_noCM(inx_possibleLake);
% % % % %     IceSheetIntensity = data_noCM(Mask_noRock == 1 & QQQQ < NotNormalHist_Thr); %)(inx_possibleIceSheet);    
% % % % %     
% % % % %     EEE = sort(SpotIntensity, 'ascend');
% % % % %     TopDark5P = EEE(ceil(length(EEE) * 0.05) );
% % % % %     TopDark10P = EEE(ceil(length(EEE) * 0.1) );
% % % % %     TopDark50P = EEE(ceil(length(EEE) * 0.5) );
% % % % %     DarkMean = mean(EEE);
% % % % %     figure(300); subplot(2,1,1); hist(SpotIntensity, 100);
% % % % %     title(['top 5%, 10%, & 50% dark: ', num2str(TopDark5P), ' ', num2str(TopDark10P), ' ',num2str(TopDark50P), '; Mean= ', num2str(DarkMean)] );
% % % % %     
% % % % %     EEE = sort(IceSheetIntensity, 'descend');
% % % % %     TopBright5P = EEE(ceil(length(EEE) * 0.05) );
% % % % %     figure(300); subplot(2,1,2); hist(IceSheetIntensity, 100);
% % % % %     title(['top 5% bright: ', num2str(TopBright5P), '; dark lake/ bright ice: ', num2str(TopDark5P/TopBright5P)] );
% % % % %     
% % % % %     disp(' ')
% % % % %     disp(['5% Bright and ratio:',num2str(TopBright5P),' ',num2str(TopDark5P/TopBright5P), '; top 5%, 10%, & 50% dark: ', num2str(TopDark5P), ' ', num2str(TopDark10P), ' ',num2str(TopDark50P), '; Mean= ', num2str(DarkMean)]);
% % % % % 
% % % % %     
% % % % %     temp = data_noCM;
% % % % %     temp(inx_possibleLake) = 1;
% % % % % figure(301); imshow(temp, [0,1], 'InitialMagnification', 67)    
% % % % % figure(400); subplot(1,5,2); imshow(temp, [0,1], 'InitialMagnification', 67);
% % % % % 
% % % % % % % %     temp = data_noCM;
% % % % % % % %     temp(Mask_noRock == 1 & QQQQ < NotNormalHist_Thr) = 1;
% % % % % % % % figure(302); imshow(temp, [0,1], 'InitialMagnification', 67)
% % % % % 
% % % % % temp = data_noCM; temp(Mask_noRock == 1 & QQQQ >= NotNormalHist_Thr & data_noCM<TopBright5P*0.3) = 1;
% % % % % figure(303); imshow(temp, [0,1], 'InitialMagnification', 67)
% % % % % figure(400); subplot(1,5,3); imshow(temp, [0,1], 'InitialMagnification', 67);
% % % % % 
% % % % % temp = data_noCM; temp(Mask_noRock == 1 & QQQQ >= NotNormalHist_Thr & data_noCM<TopBright5P*0.5) = 1;
% % % % % figure(304); imshow(temp, [0,1], 'InitialMagnification', 67)
% % % % % figure(400); subplot(1,5,4); imshow(temp, [0,1], 'InitialMagnification', 67);
% % % % % 
% % % % % temp = data_noCM; temp(Mask_noRock == 1 & QQQQ >= NotNormalHist_Thr & data_noCM<TopBright5P*0.7) = 1;
% % % % % figure(305); imshow(temp, [0,1], 'InitialMagnification', 67)
% % % % % figure(400); subplot(1,5,5); imshow(temp, [0,1], 'InitialMagnification', 67);
% % % % % 
% % % % %     keyboard;
% % % % % end
% ----------------------    
    
    end
    
    %---- see result compare to Otsu's threshold ----
% % % % % %     if (~isempty(inx_possibleLake))
% % % % % %         tt1 = double(data_noCM);
% % % % % %         temp = zeros([size(tt1),3]);
% % % % % % 
% % % % % %         tt2 = tt1;
% % % % % %         tt2(inx_possibleLake) = 1; %255; % red
% % % % % %         tt2(Mask_noRock == 0) = 0;
% % % % % %         temp(:,:,1) = tt2;
% % % % % % 
% % % % % %         tt2 = tt1;
% % % % % %         tt2(inx_possibleLake) = 0;    
% % % % % %         tt2(Mask_noRock == 0) = 0;
% % % % % %         temp(:,:,2) = tt2;
% % % % % %         temp(:,:,3) = tt2;    
% % % % % % 
% % % % % %         figure(4); imshow(temp, [NotSignal, 1]);
% % % % % %         title(['Seed: NotNormal_Thr=', num2str(NotNormalHist_Thr)]);
% % % % % %     end
% % % % % %     
% % % % % %     
% % % % % %     keyboard;
    
%% Yuli:KEEP: plot histogram etc.    
% % % % % if (PlotFigure == 1)        
% % % % % NotSignal = -0.01;
% % % % %         % ---- plot histogram (averaged one) -----
% % % % %         figure(1); subplot(2,1,1); 
% % % % %         hist(QQQQ_1D, BinCenter); hold on;
% % % % %         temp = (N_AvePoint-1)/2;
% % % % %         plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp)) , ...
% % % % %             RightHist_gt0_Ave, 'r-');
% % % % %         hold off;
% % % % %         
% % % % %         % --- plot detail view of histogrm ----
% % % % %         figure(1); subplot(2,1,2); 
% % % % %         hist(QQQQ_1D, BinCenter); hold on;
% % % % %         temp = (N_AvePoint-1)/2;
% % % % %         RightBinCenter = BinCenter(N_LeftBin+1:end);
% % % % %         plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp)) , ...
% % % % %             RightHist_gt0_Ave, 'r-');
% % % % %         hold off;
% % % % %         axis([min(QQQQ_1D), max(QQQQ_1D), 0, 30]);
% % % % %     %     title(['Lake threshold is: ',num2str(LakeValueThr)]);
% % % % % 
% % % % %         % ----- plot average 1st / 2nd derivitive ----
% % % % %         temp = (N_AvePoint-1)/2 + (N_AvePoint_Deri-1)/2;
% % % % %         figure(4);
% % % % %         plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp-1)), ...
% % % % %             RightHist_1stDeri_Ave, 'b-');
% % % % %         hold on;
% % % % % % %         plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp-2)), ...
% % % % % % %             RightHist_2ndDeri_Ave, 'r-');
% % % % %         hold off;   grid on;
% % % % %     %     axis([min(RightBinCenter), max(RightBinCenter), -0.4, 0.4]);
% % % % %         title([' Ave. 1st deri.(blue).  Ave. 2nd deri.(red) . Histogram thr= ', num2str(NotNormalHist_Thr)]);
% % % % % 
% % % % %         % ----- plot the origianl image ----
% % % % %         
% % % % %         figure(2); imshow(data_noCM.*Mask_noRock, [NotSignal, 0.9]);    
% % % % %         title(['min:',num2str(min(QQQQ_1D)),', max:',num2str(max(QQQQ_1D)), ...
% % % % %             ' Left std:', num2str(Left_std), ' Right std:', num2str(Right_std), ...
% % % % %             ' Right/Left std:', num2str(Right_std/Left_std), ...
% % % % %             ' *',num2str(NotNormalHist_Thr/Left_std),' *',num2str(NotNormalHist_Thr/Right_std) ]);
% % % % % 
% % % % %         % --- plot 2nd derivitive ---
% % % % % % % % % % %     RightHist_2ndDeri = RightHist_1stDeri_Ave(1:end-1) - RightHist_1stDeri_Ave(2:end);
% % % % % % % % % % %     temp = (N_AvePoint-1)/2 + (N_AvePoint_Deri-1)/2;
% % % % % % % % % % %     figure(5); subplot(3,1,3); plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp-2)), ...
% % % % % % % % % % %         RightHist_2ndDeri, 'g-');    
% % % % % % % % % % %     title('2nd derivitive'); grid on;
% % % % %     % ----- distance plot. Hard to see the threshold ---
% % % % %     % could average it and try more when another way is not working.
% % % % % % % % %     [QQQQ_1D, dump_inx] = sort(QQQQ_1D, 'ascend');
% % % % % % % % %     QQQQ_dist = QQQQ_1D(2:end) - QQQQ_1D(1:end-1);
% % % % % % % % %     figure(10); plot(QQQQ_1D(1:end-1), QQQQ_dist, 'b-');
% % % % %     % ----- plot 1st derivitive  ----
% % % % % % % % % %     temp = (N_AvePoint-1)/2;
% % % % % % % % % %     figure(5); subplot(3,1,1); plot(RightBinCenter(RightHist_gt0_inx(temp+1:end-temp-1)), ...
% % % % % % % % % %         RightHist_1stDeri, 'r-');    
% % % % % % % % % % %     axis([min(RightBinCenter), max(RightBinCenter), -0.4, 0.4]);
% % % % % % % % % %     title('1st derivitive'); grid on;    
% % % % %         
% % % % %         % ----- plot the origianl image with overlapped threshold ----
% % % % %     if (~isempty(inx_possibleLake))        
% % % % %         tt1 = double(data_noCM);
% % % % %         temp = zeros([size(tt1),3]);
% % % % % 
% % % % %         tt2 = tt1;
% % % % %         tt2(inx_possibleLake) = 1; %255; % red
% % % % %         tt2(Mask_noRock == 0) = 0;
% % % % %         temp(:,:,1) = tt2;
% % % % % 
% % % % %         tt2 = tt1;
% % % % %         tt2(inx_possibleLake) = 0;    
% % % % %         tt2(Mask_noRock == 0) = 0;
% % % % %         temp(:,:,2) = tt2;
% % % % %         temp(:,:,3) = tt2;    
% % % % % 
% % % % %         figure(3); imshow(temp, [NotSignal, 1]);
% % % % %         title(['Seed: NotNormal_Thr=', num2str(NotNormalHist_Thr)]);
% % % % %     end
% % % % %     
% % % % %     
% % % % % end

end


% % % temp1 = zeros(size(data_noCM));
% % % temp1(inx_possibleLake_core_1) = 1; % detected lake of 1x1 core
% % % temp2 = zeros(size(data_noCM));
% % % temp2(inx_possibleLake) = 1; % detected lake of 5x5 core
% % % 
% % % inx_possibleLake = find(temp1 == 1 & temp2 == 1);




%     inx_possibleLake_core_1 = inx_possibleLake;
% % % % inx_possibleLake_core_5 = inx_possibleLake;

function [] = StructureElement(ii_core_1, ii_core_3)
global DotK_core_1 DotK_outside_1
global DotK_core_3 DotK_outside_3
global ii_outside

for ii =1:1:2
    if ii == 1
        ii_core = ii_core_1;
    else
        ii_core = ii_core_3;
    end
    
    DotK_outside = zeros(ii_outside,ii_outside);
    DotK_core = zeros(ii_core,ii_core);

    layer_core = (ii_core-1)/2; 
    for jj = 1:1:layer_core
        DotK_core(jj, jj:ii_core-jj) = 1/(ii_core-2*jj + 1); % /4 , core
    end
    DotK_core(layer_core+1, layer_core+1) = 1; % middle points
    DotK_core = DotK_core + rot90(DotK_core,1) + rot90(DotK_core,2) + rot90(DotK_core,3);

    layer_outside = (ii_outside-ii_core)/2; 
    for jj = 1:1:layer_outside
        DotK_outside(jj, jj:ii_outside-jj) = 1/(ii_outside-2*jj + 1); % /4 , outside
    end

    DotK_outside = DotK_outside + rot90(DotK_outside,1)+ rot90(DotK_outside,2)+ rot90(DotK_outside,3);

    if ii == 1
        DotK_core_1 = DotK_core; 
        DotK_outside_1 = DotK_outside;
    else
        DotK_core_3 = DotK_core; 
        DotK_outside_3 = DotK_outside;
    end

end

% report only large spot (rough report) in the effective area for image selection
% based on "SingleImg_Lake_Seed"
function [inx_possibleLake, message] = FindRoughSeed...
    (data_noCM, Mask_noRock, N_Bin, N_AvePoint, N_AvePoint_Deri, ...
     AlmostZero_1stDeri)
% mlock
global DotK_core_3 DotK_outside_3

message = '';
% ii_core = 3; % odd number 3,5,7,etc. make sure even lines
inx_possibleLake = [];

% for tttt = 1:1:1 

% ----- mechanisem: dot kernel + threshold -----
% if maximum lake is about 3km x 3km (12 pixel * 12 pixel)
% core need to be cover the size at least up to this size
% and core size is about (0.5*KernelSize)^2
%
% concatenate the result of sveral different size of kernels

% ----- define core / outside kernel ------

C_core = conv2(data_noCM, DotK_core_3, 'same'); % when core larger than 1 pixel, should consider Mask
C_core = C_core./sum(sum(DotK_core_3)); 
    
%         NotNormalHist_Thr = 0.14;
% % kkk = 1;
% % while (kkk == 1)    
    %  for LakeValueThr = 0.0:0.02:0.4
    
    Mask_noLake = double(Mask_noRock);
    Mask_noLake(inx_possibleLake) = 0;
    
    C_outside_weight = conv2(Mask_noLake, DotK_outside_3, 'same');
    C_outside_value = conv2(data_noCM.*Mask_noLake, DotK_outside_3, 'same');    
% %     C_outside_weight = conv2(Mask_noRock, DotK_outside_3, 'same');
% %     C_outside_value = conv2(data_noCM.*Mask_noRock, DotK_outside_3, 'same');    
    C_outside = C_outside_value./C_outside_weight;
    QQQQ = (C_outside - C_core); % no normalized
    QQQQ_1D = QQQQ(Mask_noRock == 1);

    
        %============ automatic setting threshold by feature historgram
        %(no normalized one) =========
% % % % % Ave_element_each_Bin = length(QQQQ_1D)/N_Bin;
% % % % % fprintf(['total / N_Bin = ', num2str(Ave_element_each_Bin), '\n'] );

        % --- define Bin ---
        BinSize = ( max(QQQQ_1D)-min(QQQQ_1D) )/N_Bin;
        N_LeftBin = -1* (floor(min(QQQQ_1D)/BinSize));
        N_RightBin = ceil(max(QQQQ_1D)/BinSize);
        BinCenter = -1*N_LeftBin + 1:1:N_RightBin;
        BinCenter = (BinCenter- 1/2) .*  BinSize;
        BinCount = hist(QQQQ_1D, BinCenter);
        RightBinCenter = BinCenter(N_LeftBin+1:end);
        
        % ===== observe standard deviation =====
        Hist_gt_0 = QQQQ_1D(QQQQ_1D >= 0);
        Hist_gt_0_2side = [-1*Hist_gt_0; Hist_gt_0];
        Right_std = std(Hist_gt_0_2side);

        Hist_lt_0 = QQQQ_1D(QQQQ_1D <= 0);
        Hist_lt_0_2side = [Hist_lt_0; -1*Hist_lt_0];
        Left_std = std(Hist_lt_0_2side);

        % ----- Use STD to see which types (1) no lakes (2) with lakes ----
        if (Right_std/Left_std < 1.1)
            message = 'RightDivideLeftStd_lt1.1'; %'Right std/ left std < 1.1, assume no lakes';
            return;
        end

        % --- only use the bin with element in it ----
    %     BinCount(1:N_LeftBin); % left histogram
        RightHist = BinCount(N_LeftBin+1:end); % right histogram
        RightHist_gt0_inx = find(RightHist > 0); % find bins which at least have one element
        RightHist_gt0 = RightHist(RightHist > 0);
        
        % ==== moving average of historgram, 1st deri =====
        % --- find the moving average of histogram, calculate the 1st derivitive
        temp = (N_AvePoint-1)/2;
    %     RightHist_1stDeri_Ave5 = RightHist_1stDeri(temp+1+temp:end-temp+temp);    
        RightHist_gt0_Ave = RightHist_gt0(N_AvePoint:end);    
        for jj = -temp:1:temp-1
            RightHist_gt0_Ave = RightHist_gt0_Ave + RightHist_gt0(temp+1+jj:end-temp+jj);
        end
        RightHist_gt0_Ave = RightHist_gt0_Ave./N_AvePoint;  
        RightHist_1stDeri = RightHist_gt0_Ave(1:end-1) - RightHist_gt0_Ave(2:end);  
% %         RightHist_2ndDeri = RightHist_1stDeri(1:end-1) - RightHist_1stDeri(2:end);  % hould use 2nd derivitive = 0 (upper contour and straight line)

        % ----- calcualte moving average of 1st derivitive ---    
        temp = (N_AvePoint_Deri-1)/2;
    %     RightHist_1stDeri_Ave5 = RightHist_1stDeri(temp+1+temp:end-temp+temp);    
        RightHist_1stDeri_Ave = RightHist_1stDeri(N_AvePoint_Deri:end);    
        for jj = -temp:1:temp-1
            RightHist_1stDeri_Ave = RightHist_1stDeri_Ave + RightHist_1stDeri(temp+1+jj:end-temp+jj);
        end
        RightHist_1stDeri_Ave = RightHist_1stDeri_Ave./N_AvePoint_Deri;     


        % ========= find the desired threshold =====
        % --- when 1st derivitive < AlmostZero_1stDeri----
        HistThr_inx = find((RightHist_1stDeri_Ave < AlmostZero_1stDeri), 1,'first');

    if ( isempty(HistThr_inx) )
        message = ['No1stDeriEqualTo',num2str(AlmostZero_1stDeri)]; %['No 1st deritive is equal to ',num2str(AlmostZero_1stDeri)];
        return;
    else    
        % -------- area below current threshold ------------------
        temp = (N_AvePoint-1)/2 + (N_AvePoint_Deri-1)/2;
        NotNormalHist_Thr = RightBinCenter(RightHist_gt0_inx(temp+HistThr_inx));
        
        inx_possibleLake = find(Mask_noRock == 1 & QQQQ >= NotNormalHist_Thr);
        % inx_possibleLake = find((data_noCM <LakeValueThr) & (Mask_noRock == 1));
        %     inx_possibleLake = (QQQQ_1 > possibleThr);        
    end

% end


%%function [] = PlotLakes(Inx, Inx_pre, InpF, ll, NotSignal) %% plot the found lakes
% % % 
% % % if (ll == 3) % RGB
% % %     tt1 = double(InpF);
% % %     tt2 = tt1(:,:,1);
% % %     for ii = 1:1:length(Inx)
% % %         tt2(Inx(ii))= 255;    
% % %     end
% % %     tt1(:,:,1) = tt2;
% % % 
% % %     tt2 = tt1(:,:,2);
% % %     for ii = 1:1:length(Inx)
% % %         tt2(Inx(ii))= 0;    
% % %     end
% % %     tt1(:,:,2) = tt2;
% % % 
% % % 
% % %     tt2 = tt1(:,:,3);
% % %     for ii = 1:1:length(Inx)
% % %         tt2(Inx(ii))= 0;    
% % %     end
% % %     tt1(:,:,3) = tt2;
% % %     
% % %     tt1 = uint8(tt1);
% % %     figure; imshow(tt1);
% % %     title('Detected lakes (red area) and origianl image');
% % %     
% % % else  % gray scale image
% % %     tt1 = double(InpF);
% % %     Maxtt1 = max(max(tt1));
% % %     figure(200); %subplot(1,2,1); 
% % %     
% % %     imshow(tt1, [NotSignal, Maxtt1]);
% % %     title('origianl image');
% % %     
% % %     temp = zeros([size(tt1),3]);
% % % 
% % %     tt2 = tt1;
% % %     tt2(Inx_pre) = Maxtt1; % previous: red
% % %     temp(:,:,1) = tt2;
% % % 
% % %     tt2 = tt1;
% % %     tt2(Inx_pre) = 0;    
% % %     temp(:,:,2) = tt2;
% % %     temp(:,:,3) = tt2;
% % %     
% % % %     temp = uint8(temp); % this is for the 0~255 images
% % %     figure(201); %subplot(1,2,2); 
% % %     
% % %     imshow(temp, [NotSignal, Maxtt1]);
% % %     title('Lake Detection (1 image)');
% % %     
% % % %     title('previous image: Detected lakes (red area) and origianl
% % % %     image');
% % %     
% % % % % % % %     tt2 = tt1;
% % % % % % % %     tt2(Inx) = 0; % current: blue
% % % % % % % %     temp(:,:,1) = tt2;
% % % % % % % %     temp(:,:,2) = tt2;
% % % % % % % % 
% % % % % % % %     tt2 = tt1;
% % % % % % % %     tt2(Inx) = Maxtt1;
% % % % % % % %     temp(:,:,3) = tt2;
% % % % % % % %     
% % % % % % % % %     temp = uint8(temp); % this is for the 0~255 images
% % % % % % % %     figure(199); imshow(temp, [NotSignal, Maxtt1]);
% % % % % % % %     title('current image: Detected lakes (blue area) and origianl
% % % % image');
% % %     
% % % end

%% ----------- detect the Ice/Rock Mask --------------
% old function. When grid cloud mask is from MOD35, which is embeded in the
% MOD02 file
% % % % % % % % % % % function IceRockMask_MOD35embededInMOD02
% % % % % % % % % % % 
% % % % % % % % % % % MaskSource = 2; 
% % % % % % % % % % % % 0: manually draw one, 1:saved automatic result  2: automatic detected
% % % % % % % % % % % 
% % % % % % % % % % % if (1) % used saved result from automatically detected mask
% % % % % % % % % % %     load Mask_ice_rock_2
% % % % % % % % % % % else
% % % % % % % % % % %     if (MaskSource == 0) % use the manully plot one
% % % % % % % % % % %         IM_FullSize = imread('OO_Mask.png', 'png'); %derive from image 313
% % % % % % % % % % %         % could be calculate from image 313 and do the erosion/dilation
% % % % % % % % % % % 
% % % % % % % % % % %         Mask_ice_rock = single(IM_FullSize(:,:,1));
% % % % % % % % % % %         Mask_ice_rock(Mask_ice_rock == 255) = 1;
% % % % % % % % % % %         Mask_ice_area = sum(sum(Mask_ice_rock));
% % % % % % % % % % %         % % figure; imshow(Mask_ice_rock, [0,1]); title('OO_Mask');
% % % % % % % % % % % 
% % % % % % % % % % %     elseif (MaskSource == 1) % saved automatica detected result
% % % % % % % % % % %         load Mask_ice_rock
% % % % % % % % % % %         load temp
% % % % % % % % % % %     else % automatically detect ice/rock mask, use only bright and less cloudy images
% % % % % % % % % % %         % 46.11 seconds
% % % % % % % % % % % 
% % % % % % % % % % %       year = 2009;
% % % % % % % % % % %         
% % % % % % % % % % %       Mask_ice_rock = Mask_All_0;
% % % % % % % % % % % 
% % % % % % % % % % %       for DD = Day_start:1:Day_end
% % % % % % % % % % % 
% % % % % % % % % % %         fprintf([' (Ice/Rock Mask) Day : ',num2str(DD), '\n'])    ;
% % % % % % % % % % %         ImgList = DIRR([MOD02_Dir, '*',num2str(year),num2str(DD),'*rad*ch01*.img']); 
% % % % % % % % % % %         % use the radiance one because of the scale is 0 to hundreds
% % % % % % % % % % %         % reflectance is about 0 ~ 1
% % % % % % % % % % %         N_Img = size(ImgList,1);
% % % % % % % % % % % 
% % % % % % % % % % %         for ii = 1:1:N_Img
% % % % % % % % % % %             Current_Img = ImgList(ii,1).name;
% % % % % % % % % % % 
% % % % % % % % % % %             fid = fopen([MOD02_Dir, Current_Img], 'rb');
% % % % % % % % % % %             data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);
% % % % % % % % % % %             data_noCM = data';
% % % % % % % % % % %             data_noCM(data_noCM >1000) = 0; % >1000 is not a valid value, most of time 1690 something
% % % % % % % % % % % 
% % % % % % % % % % %             fid = fopen([withCM_Dir, Current_Img], 'rb');
% % % % % % % % % % %             data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);
% % % % % % % % % % %             data_CM = data';
% % % % % % % % % % %             data_CM(data_CM >1000) = 0; % set cloudy pixel as zero
% % % % % % % % % % % 
% % % % % % % % % % %             Mask = Mask_All_1; % initialize cloud mask
% % % % % % % % % % %             Mask(data_CM == 0) = 0; % cloud mask + no data part, still inclue rock
% % % % % % % % % % % 
% % % % % % % % % % %       % ----------- choose the best picture for Ice/Rock detection -----
% % % % % % % % % % %             Mask_noCloud_area = sum(sum(Mask));
% % % % % % % % % % %             temp = data_CM.*Mask;
% % % % % % % % % % %             brightness = sum(sum(temp)) /Mask_noCloud_area;
% % % % % % % % % % % 
% % % % % % % % % % %             if (Mask_noCloud_area > Img_rr * Img_cc * 0.8 && ...
% % % % % % % % % % %                     brightness > 100) 
% % % % % % % % % % % 
% % % % % % % % % % %                 Mask_temp = IceMask(data_noCM); % produce ICE/Rock mask, use *.img # 313
% % % % % % % % % % %                 Mask_temp(Mask_temp == 0) = -1;
% % % % % % % % % % %                 Mask_ice_rock = Mask_ice_rock + Mask_temp;
% % % % % % % % % % % 
% % % % % % % % % % %     % %             temp = data_noCM .* Mask_temp;
% % % % % % % % % % %     % %             figure(200); imshow(temp, [0,max(max(temp))] ); title('data with ice/rock mask');
% % % % % % % % % % % 
% % % % % % % % % % %             end
% % % % % % % % % % %         end    
% % % % % % % % % % %       end
% % % % % % % % % % %       Mask_ice_rock(Mask_ice_rock > 0) = 1;
% % % % % % % % % % %       Mask_ice_rock(Mask_ice_rock < 0) = 0;
% % % % % % % % % % %       Mask_ice_area = sum(sum(Mask_ice_rock));
% % % % % % % % % % % 
% % % % % % % % % % %       save Mask_ice_rock Mask_ice_area Mask_ice_rock
% % % % % % % % % % % 
% % % % % % % % % % %     end
% % % % % % % % % % % 
% % % % % % % % % % % % % % % temp = save_data_noCM .* Mask_ice_rock;
% % % % % % % % % % % % % % % figure(221); imshow(temp, [0,max(max(temp))] ); title('data with final
% % % % % % % % % % % % % % ice/rock mask');
% % % % % % % % % % % % % figure(220); imshow(Mask_ice_rock, [0,1] ); title('final ice/rock mask');
% % % % % % % % % % % % % keyboard;
% % % % % % % % % % % 
% % % % % % % % % % % % further erosion / dilation, to get rid of the margin of the ice shield
% % % % % % % % % % %     Mask = Mask_ice_rock;
% % % % % % % % % % %         for jj = 1:1:13 %erosion % get rid of margin / small spike
% % % % % % % % % % %             Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
% % % % % % % % % % %             Mask = (Mask_temp == 9);
% % % % % % % % % % % %                     figure(6); imshow(Mask, [0,1]);                    
% % % % % % % % % % %         end
% % % % % % % % % % %         
% % % % % % % % % % %         for jj = 1:1:13 %Dilation % get it back
% % % % % % % % % % %             Mask_temp = (conv2(single(Mask), KERNEL, 'same')); % 'valid' or 'same'
% % % % % % % % % % %             Mask = (Mask_temp > 0);
% % % % % % % % % % % %                     figure(5); imshow(Mask, [0,1]);
% % % % % % % % % % % % % %         temp = save_data_noCM .* Mask;
% % % % % % % % % % % % % % figure(222); imshow(temp, [0,max(max(temp))] ); title('data with final ice/rock mask');
% % % % % % % % % % % % % % figure(223); imshow(save_data_noCM, [0,max(max(save_data_noCM))] ); title('final ice/rock mask');                    
% % % % % % % % % % %         end
% % % % % % % % % % %     Mask_ice_rock = Mask;
% % % % % % % % % % %     Mask_ice_area = sum(sum(Mask_ice_rock));
% % % % % % % % % % %     save Mask_ice_rock_2 Mask_ice_rock Mask_ice_area % the Ice/Rock mask after erosion / dilation
% % % % % % % % % % % end

%% =========== Test MOD10_L2: Cloud Mask & Rock/Ice Mask ==============
% % %  current plan, (1) cloud mask (snow == 50), 
% (2) browse multiple snow cover land, , choose one rock/ice mask


% % % % % % % % for ii = 1:1:4
% % % % % % % % Current_Img = ['yuli_',num2str(ii),'_rawm_snow_00500_01000.img'];
% % % % % % % % fid = fopen([MOD10_L2_Dir, Current_Img], 'rb');
% % % % % % % % data = fread(fid, [Img_cc, Img_rr], 'uint8');  fclose(fid);
% % % % % % % % data_snow = data';
% % % % % % % % % figure(1); imshow(data_snow, [0, 300 ]);
% % % % % % % % 
% % % % % % % % Current_Img = ['yuli_',num2str(ii),'_rawm_snqa_00500_01000.img'];
% % % % % % % % fid = fopen([MOD10_L2_Dir, Current_Img], 'rb');
% % % % % % % % data = fread(fid, [Img_cc, Img_rr], 'uint8');  fclose(fid);
% % % % % % % % data_snqa = data';
% % % % % % % % % figure(2); imshow(data_snqa, [0, 300 ]);
% % % % % % % % 
% % % % % % % % Current_Img =[num2str(ii),'_refm_ch01_00500_01000.img'];
% % % % % % % % fid = fopen([MOD10_L2_Dir, Current_Img], 'rb');
% % % % % % % % data = fread(fid, [Img_cc, Img_rr], 'float32');  fclose(fid);
% % % % % % % % data = data';
% % % % % % % % figure(3); imshow(data, [0, 1 ]);
% % % % % % % % 
% % % % % % % % figure(4); imshow((data_snow == 200), [0,1]); % snow cover land. could detect most of ice area, and exclude out cloudy area. 
% % % % % % % % title('snow cover land, no cloud part');
% % % % % % % % 
% % % % % % % % figure(5); imshow((data_snow == 50), [0,1]); % cloud mask
% % % % % % % % title('cloud');
% % % % % % % % 
% % % % % % % % figure(6); imshow((data_snow == 25), [0,1]); % lots lakes are identified as land
% % % % % % % % title('land');
% % % % % % % % 
% % % % % % % % % http://nsidc.org/data/docs/daac/mod10_modis_snow/version_5/mod10l2_local_attributes.html#snowcoverpixelfield
% % % % % % % % 
% % % % % % % % keyboard;
% % % % % % % % end
% % % % % % % % 
% % % % % % % % return;
% % % % % % % % 
