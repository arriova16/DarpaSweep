%Darpa Sweep Mechanical 
%goals I want to be able pull files and be able to formatt them here
%I also want to be able to save those formatted files and analyze them

data_folder = 'B:\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_12and22\SweepTask';
  % process_loc = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\ProcessedData\Pinot';

% data_folder ='B:\ProjectFolders\DARPA\Data\RawData\Whistlepig\Electrodde_3and15\SweepTask';

file_list = dir(data_folder);

%% Loading folders
%load folders then load files from there 
%save formatted mat files



%loading electdetect folder
elect = fullfile(data_folder, 'ElectDetect');
elect_file = dir(fullfile(elect, '*rsp'));
    
%loading mechdetect folder
mech = fullfile(data_folder, 'MechDetect');
mech_file = dir(fullfile(mech, '*rsp'));


%formatting electdetect files name
for e = 1:size(elect_file,1)

    %getting monkey name and sess date for file name

    name_split = strsplit(elect_file(e).name, '_');
    us_idx = find(elect_file(e).name == '_', 1, 'last');
    dt_string = elect_file(e).name(us_idx(1)+1:end-4);
    dt_split = strsplit(dt_string, 'T');
    exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
    monkey_name = name_split{2}(1:end -7);
    fname = sprintf('%s_%s_ElectDetect.mat', monkey_name, exp_date);
    
    if exist(fullfile(elect,fname), 'file') ~= 1 || overwrite
        %loading and formatting data
        raw_data = readcell(fullfile(elect, elect_file(e).name), ...
            'FileType','text', 'NumHeaderLines', 1);
     
        ElectDetect_Table = ElectDetectFormatter(raw_data);

        save(fullfile(elect,fname), 'ElectDetect_Table')
    end

end

%formatting MechDetect folder

for m = 1:size(mech_file,1)
    %getting monkey name and sess date for file name
    name_split = strsplit(mech_file(m).name, '_');
    monkey_name  = name_split{2}(1:end-7);
    dt_name = name_split{4}(1:end-4);
    dt_split = strsplit(dt_name, 'T');
    exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
    fname = sprintf('%s_%s_MechDetect.mat', monkey_name, exp_date);
    
    if exist(fullfile(mech, fname), 'file') ~= 1 || overwrite 

    %loading and formatting data
        raw_data = readcell(fullfile(mech, mech_file(m).name), ...
            "FileType","text", 'NumHeaderLines', 1);
        
        MechDetect_Table = MechDetectFormatter(raw_data);

        save(fullfile(mech,fname), 'MechDetect_Table')
    end

end


%%
block_struct =struct();
data = struct();

    subf_mech = fullfile(data_folder, 'MechDetect');
    subf_elect = fullfile(data_folder, 'ElectDetect');
    elect_file_list = dir(fullfile(subf_elect, '*.mat'));
    mech_file_list = dir(fullfile(subf_mech, '*.mat'));
    elect_table = cell(size(elect_file_list,1),1);
    mech_table = cell(size(mech_file_list,1),1);

    for b = 1:size(mech_file_list,1)
      for c = 1:size(elect_file_list)
         fname_split = strsplit(mech_file_list(b).name, '_');
         monkey_name = fname_split{1};
         block_struct(b).Date = fname_split{2};
         temp_mech = load(fullfile(mech_file_list(b).folder, mech_file_list(b).name));
         mech_table{b} = [temp_mech.MechDetect_Table];
         block_struct(b).MechRT = mech_table{b};
         temp_elect = load(fullfile(elect_file_list(c).folder, elect_file_list(c).name)); 
          elect_table{c} = [temp_elect.ElectDetect_Table];
          block_struct(c).ElectRT =elect_table{c};


      end
    end
   
data.MechDetectTable = cat(1,mech_table{:});
data.ElectDetectTable = cat(1,elect_table{:});


% save_fname = sprintf('%s_ME_comb.mat', monkey_name);
% if exist(fullfile(process_loc, save_fname), 'file') ~=1 || overwrite
% 
%     save(fullfile(process_loc, save_fname), 'data')
% end


%% putting things into block - will need to concat response tables?
%coding not rounding correctly- if pdetect is zero then dprime should be
%negative but its 4

for i = 1:length(data)
    for d = 1:length(block_struct)
        [MechDetect_DT] = AnalyzeMechTable(data.MechDetectTable);
          [dbd_mech_dt{d}]= AnalyzeMechTable(block_struct(d).MechRT(:,:));
         block_struct(d).MechDT_daily = dbd_mech_dt{d};
         x_mech = MechDetect_DT.MechAmp;
         y_mech_dprime = MechDetect_DT.dPrime;
 
         %works for pinot

          [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime, 'NumCoeffs', 3,'Constraints', [0, 200; -5, 5],  'PlotFit', true);
          
       % [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime,...
       %     'NumCoeffs', 4, 'CoeffInit', [400,0.02,NaN,NaN], 'EnableBackup', false, 'PlotFit', true);
       %x-offset completely off/ look at plot first/ dont just plug in
       %random numbers

        % plot(x_mech, y_mech_dprime)

         %for wp
         % [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime,...
         % 'NumCoeffs', 3, 'CoeffInit', [400,0.02,NaN,NaN], 'EnableBackup', false, 'PlotFit', true);
         % % 'PlotFit', true, 'CoeffInit', [1,15,NaN,NaN], 'NumCoeffs', 3, 'EnableBackup', false);


        %analysis for electrical table

       
        [ElectDetect_DT] = AnalyzeElectTable(data.ElectDetectTable);
        [dbd_elect_dt{d}] = AnalyzeElectTable(block_struct(d).ElectRT(:,:));
        block_struct(d).ElectDT_daily = dbd_elect_dt{d};
        x_elect = ElectDetect_DT.StimAmp;
        y_elect = ElectDetect_DT.dPrime;
         
         %coeffs are the issues/ constraints
        %works for pinot
       [~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', 3,'CoeffInit', [.5,15,NaN,NaN],'PlotFit', true);

       %  %wp
       % [~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', ...
           % 3,'CoeffInit', [1,17,NaN, NaN], 'EnableBackup', false, 'PlotFit', true);
       %  % plot(x_elect,y_elect)
%      'NumCoeffs', 4,'Constraints', [0, 500; -10, 10]'CoeffInit', [0,200,NaN,NaN]
% CoeffInit', [1,17,NaN, NaN], 'EnableBackup', false, 'PlotFit', true);
 
    end
end

%% Plotting
%c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4);

 %was getting error with above sigmoid because it was expecting 4 but only
 %giving 3
 siggyfun = GetSigmoid(3); 
for i = 1:length(block_struct)
dprime_threshold = 1.35;
 SetFont('Arial', 18)
%plotting Mech Detection pdetect and dprime
subplot(2,2,1); hold on 
title('Mech pDetect')
scatter(MechDetect_DT.MechAmp,MechDetect_DT.pDetect , 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp,MechDetect_DT.pDetect,'Color', [.1 .1 .1], 'LineStyle', '-')

%plotting day by day
c = ColorGradient(rgb(207, 216, 220), rgb(33, 33, 33), length(block_struct));
% colormap(flipud(parula))
% c = flipud(parula(length(block_struct)));
plot(block_struct(i).MechDT_daily{:,1}, block_struct(i).MechDT_daily{:,2}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)
axis square
xlabel('Amplitude (mm)','FontSize', 18)
ylabel('pDetect','FontSize',18) 
ylim([0 1.02])
text(0.05,.3, 'First Session', 'Color', rgb(207, 216, 220), 'FontSize', 18)
text(0.05,.23, 'Latest Session', 'Color',rgb(33, 33, 33), 'FontSize',18)

subplot(2,2,2); 
hold on; title('Mech dPrime')

scatter(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle', '-')
plot(block_struct(i).MechDT_daily{:,1}, block_struct(i).MechDT_daily{:,3}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)

axis square
 xq = linspace(0, x_mech(end));
 yq = siggyfun(coeffs,xq);
 [~, b] = min(abs(yq-dprime_threshold));
 plot(xq,yq,'Color', [.1 .1 .1])
 plot([0 xq(b) xq(b)], [dprime_threshold, dprime_threshold, 0], 'Color',rgb(69, 90, 100),'LineStyle','--')
  text(.07,0,(sprintf('%.3f',xq(b))), 'Color', rgb(26, 35, 126), 'FontSize',18);
 xlabel('Amplitude (mm)','FontSize', 18)
 ylabel('d''','FontSize',18)
 ylim([-.6 5])


subplot(2,2,3); hold on; title('Elect pDetect')

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 'Color', [.1 .1 .1], 'LineStyle', '-')
plot(block_struct(i).ElectDT_daily{:,1}, block_struct(i).ElectDT_daily{:,2}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)

axis square
 xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('pDetect','FontSize',18)
ylim([0 1.02])

 subplot(2,2,4); hold on; title('Elect dPrime')

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle', '-')
plot(block_struct(i).ElectDT_daily{:,1}, block_struct(i).ElectDT_daily{:,3}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)

axis square

 ll = 0.9;
 mm = 0.45;

 tt = linspace(0,x_elect(end));
 tq = siggyfun(coeffs_elect,tt);

 [~, np] = min(abs(tq-dprime_threshold));
 plot([0 tt(np) tt(np)], [dprime_threshold, dprime_threshold, 0], 'Color',rgb(26, 35, 126),'LineStyle', '--')
 up = (tt(np));
 text(30,1,(sprintf('%.0f',up)), 'Color', rgb(26, 35, 126), 'FontSize',18);
 % text(30,2.5,(sprintf('%.0f',up)), 'Color', rgb(26, 35, 126), 'FontSize',18);
% 
  [~, ll_np] = min(abs(tq-ll));
  lp = (tt(ll_np));
  plot([0 tt(ll_np) tt(ll_np)], [ll, ll, 0],'Color', rgb(103, 58, 183), 'LineStyle', '--')
  text(30,.5,(sprintf('%.0f',tt(ll_np))), 'Color', rgb(103, 58, 183), 'FontSize',18);
  % text(30,1.5,(sprintf('%.0f',tt(ll_np))), 'Color', rgb(103, 58, 183), 'FontSize',18);

  [~, mm_np] = min(abs(tq-mm));
  plot([0 tt(mm_np) tt(mm_np)], [mm, mm, 0], 'Color', rgb(156, 39, 176),'LineStyle', '--')
 text(30,0,(sprintf('%.0f',tt(mm_np))), 'Color', rgb(156, 39, 176), 'FontSize',18);
 % text(30,2,(sprintf('%.0f',tt(mm_np))), 'Color', rgb(156, 39, 176), 'FontSize',18);

  
 plot(tt,tq,'Color',rgb(69, 90, 100))
 xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('d''','FontSize',18)
 ylim([-.6 5])
 

 % cb = colorbar('Direction', 'reverse', 'Ticks', [0,1,3],'TickLabels',{'Newest', 'Oldest'});
 % cb.cmap = c;
 % colormap(c)
% legend('Newest','Oldest','Location','southeast')
% legend('boxoff')
end


