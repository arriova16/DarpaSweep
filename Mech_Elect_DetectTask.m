%Darpa Sweep Mechanical 
%goals I want to be able pull files and be able to formatt them here
%I also want to be able to save those formatted files and analyze them

data_folder = 'B:\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_31and41\SweepTask';
% data_folder = 'B:\ProjectFolders\DARPA\Data\RawData\Whistlepig\Electrode_12and13\SweepTask';

% process_loc = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\ProcessedData\Pinot\DarpaSweep';
%%
% data_folder ='B:\ProjectFolders\DARPA\Data\RawData\Whistlepig\Electrodde_3and15\SweepTask';
% data_folder = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\RawData';
% monkey_list = dir(data_folder);

% % for m = 3:size(monkey_list,1)
%     electrode_list = dir(fullfile(data_folder, monkey_list(m).name,'Electrode*'));
%     for e = 1:size(electrode_list,1)
%         looking into task folder
%         sweep_tld = fullfile(data_folder, monkey_list(m).name, electrode_list(e).name, 'SweepTask');
% 
% 
%         elect = fullfile(data_folder, 'ElectDetect');
%         mech = fullfile(data_folder, 'MechDetect');
% 
%         elect_file = dir(fullfile(elect, '*rsp'));
%         mech_file = dir(fullfile(mech, '*rsp'));
% 
%     end
% end
% 
% 
% 
% formatting electdetect files name
% for e = 1:size(elect_file,1)
% 
%     name_split = strsplit(elect_file(e).name, '_');
%     us_idx = find(elect_file(e).name == '_', 1, 'last');
%     dt_string = elect_file(e).name(us_idx(1)+1:end-4);
%     dt_split = strsplit(dt_string, 'T');
%     exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
%     monkey_name = name_split{2}(1:end -7);
%     fname = sprintf('%s_%s_ElectDetect.mat', monkey_name,dt_split{1});
% 
%     if exist(fullfile(elect,fname), 'file') ~= 1 || overwrite
%         loading and formatting data
%         raw_data = readcell(fullfile(elect, elect_file(e).name), ...
%             'FileType','text', 'NumHeaderLines', 1);
% 
%         ElectDetect_Table = ElectDetectFormatter(raw_data);
% 
%         save(fullfile(elect,fname), 'ElectDetect_Table')
%     end
% 
% end
% 
% for m = 1:size(mech_file,1)
%     getting monkey name and sess date for file name
%     name_split = strsplit(mech_file(m).name, '_');
%     monkey_name  = name_split{2}(1:end-7);
%     dt_name = name_split{4}(1:end-4);
%     dt_split = strsplit(dt_name, 'T');
%     exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
%     fname = sprintf('%s_%s_MechDetect.mat', monkey_name, dt_split{1});
% 
%     if exist(fullfile(mech, fname), 'file') ~= 1 || overwrite 
% 
%     loading and formatting data
%         raw_data = readcell(fullfile(mech, mech_file(m).name), ...
%             "FileType","text", 'NumHeaderLines', 1);
% 
%         MechDetect_Table = MechDetectFormatter(raw_data);
% 
%         save(fullfile(mech,fname), 'MechDetect_Table')
%     end
% 
% end


%%
block_struct =struct();
data = struct();
        % sweep_tld = fullfile(tld, monkey_list(m).name, electrode_list(e).name, 'SweepTask');
% 
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
%only concat the last 2 days
% block_struct(:,8) = block_struct(:,1);
data.ElectDetectTable = cat(1,block_struct(end-2:end).ElectRT);
data.MechDetectTable = cat(1, block_struct(end-1:end).MechRT);

% save_fname = sprintf('%s_%s_ME.mat', monkey_name, electrode_num);
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
         y_mech = MechDetect_DT.pDetect;

         %works for pinot
          plot(x_mech, y_mech)
         % pdetect
           [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech,'NumCoeffs', 4, 'CoeffInit', [200,.01,NaN,NaN],  'PlotFit', true);
           % dprime
           % [~,coeffs_mech_dprime, ~,~,~, warn_mech_dprime] = FitSigmoid(x_mech, y_mech_dprime, 'NumCoeffs', 4, 'CoeffInit', [200,.01,NaN,NaN],  'PlotFit', true);
          
       % % [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime,...
           % 'NumCoeffs', 4, 'CoeffInit', [400,0.02,NaN,NaN], 'EnableBackup', false, 'PlotFit', true);
       %x-offset completely off/ look at plot first/ dont just plug in
       %random numbers

        

         %for wp
          % [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime,...
         % 'NumCoeffs', 3, 'CoeffInit', [400,0.02,NaN,NaN], 'EnableBackup', false, 'PlotFit', true);
          

%          [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech,'Constraints', [0,200;-5, 5], 'PlotFit', true);
% 


        %analysis for electrical table

       
        [ElectDetect_DT] = AnalyzeElectTable(data.ElectDetectTable);
        [dbd_elect_dt{d}] = AnalyzeElectTable(block_struct(d).ElectRT(:,:));
        block_struct(d).ElectDT_daily = dbd_elect_dt{d};
        x_elect = ElectDetect_DT.StimAmp;
        y_elect_pdetect = ElectDetect_DT.pDetect;
        y_elect_dprime = ElectDetect_DT.dPrime;

        % 
        %works for pinot
%         dprime incorrect
       % [~,coeffs_elect_dprime,~, ~, ~, warn_elect_dprime] = FitSigmoid(x_elect,y_elect_dprime ,'NumCoeffs', 4,'CoeffInit', [1,15,NaN,NaN], 'PlotFit', true);
%         pdetect
       [~,coeffs_elect, ~,~,~, warn_elect] = FitSigmoid(x_elect, y_elect_pdetect,'NumCoeffs', 4,'CoeffInit', [1,15,NaN,NaN], 'PlotFit', true);

       %  %wp
       % [~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', ...
           % 3,'CoeffInit', [1,17,NaN, NaN], 'EnableBackup', false, 'PlotFit', true);
       %  % plot(x_elect,y_elect)
%           [~,coeffs_elect, ~,~,~, warn_elect] = FitSigmoid(x_elect, y_elect,'CoeffInit', [.2,30,NaN, NaN], 'PlotFit', true);

    end
end


%test
% plot(block_struct.ElectDT_daily.StimAmp,block_struct.ElectDT_daily.pDetect)

%% converting coeffs pdetect to dprime

%new dprime coeffs for mech
sigfun = GetSigmoid(4);

xq = linspace(0, x_mech(end));
mc = sigfun(coeffs,xq);

mech_fa = MechDetect_DT{1,2};
mech_dprime_coeffs = norminv(mc) - norminv(mech_fa);


%new dprime coeffs for elect

tt = linspace(0,x_elect(end));
ec = sigfun(coeffs_elect,tt);
elect_fa = ElectDetect_DT{1,2};
elect_dprime_coeffs = norminv(ec)- norminv(elect_fa);




%% Plotting
%c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
% sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4);
SetFont('Arial', 18)
 %was getting error with above sigmoid because it was expecting 4 but only
 %giving 3
 siggyfun = GetSigmoid(4); 
for i = 1:length(block_struct)
dprime_threshold = 1.35;

%plotting Mech Detection pdetect and dprime
subplot(2,2,1); hold on 
SetFont('Arial', 18)

title('Mech pDetect')
scatter(MechDetect_DT.MechAmp,MechDetect_DT.pDetect , 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp,MechDetect_DT.pDetect,'Color',rgb(198, 40, 40), 'LineStyle', '-')

%plotting day by day
c = ColorGradient(rgb(207, 216, 220), rgb(33, 33, 33), length(block_struct));
% colormap(flipud(parula))
% c = flipud(parula(length(block_struct)));
plot(block_struct(i).MechDT_daily{:,1}, block_struct(i).MechDT_daily{:,2}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)
axis square
xlabel('Amplitude (mm)')
ylabel('pDetect') 
ylim([0 1])

xlim([0 .03])
xticks(0:.01:.1)
xtickangle(0)
xq = linspace(0, x_mech(end));
yq = siggyfun(coeffs,xq);
% [~, b] = min(abs(yq-dprime_threshold));
plot(xq,yq,'Color',rgb(84, 110, 122))
% plot([0 xq(b) xq(b)], [dprime_threshold, dprime_threshold, -1], 'Color',rgb(69, 90, 100),'LineStyle','--')
% text(.02,.1,(sprintf('%.3f',xq(b))), 'Color', rgb(26, 35, 126));
text(0.02,.3, 'First Session', 'Color', rgb(207, 216, 220))
text(0.02,.23, 'Latest Session', 'Color',rgb(33, 33, 33))
text(0.02, .17, 'Last Two Days', 'Color',rgb(198, 40, 40))

subplot(2,2,2); 
hold on; title('Mech dPrime')
SetFont('Arial', 18)

scatter(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 'Color', rgb(198, 40, 40), 'LineStyle', '-')
plot(block_struct(i).MechDT_daily{:,1}, block_struct(i).MechDT_daily{:,3}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)

% md = siggyfun(coeffs_mech_dprime,xq);
[~, b] = min(abs(mech_dprime_coeffs-dprime_threshold));
plot([0 xq(b) xq(b)], [dprime_threshold, dprime_threshold, -1], 'Color',rgb(69, 90, 100),'LineStyle','--')
text(.02,.1,(sprintf('%.3f',xq(b))), 'Color', rgb(26, 35, 126));

plot(xq,mech_dprime_coeffs,'Color',rgb(84, 110, 122))

xlabel('Amplitude (mm)')
ylabel('d''')
ylim([-1 5])
xlim([0 .03])
xticks(0:.01:.1)
xtickangle(0)
axis square


subplot(2,2,3); hold on; title('Elect pDetect')

SetFont('Arial', 18)

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 'Color',rgb(198, 40, 40), 'LineStyle', '-')
plot(block_struct(i).ElectDT_daily{:,1}, block_struct(i).ElectDT_daily{:,2}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)

xlim([0 30])
tt = linspace(0,x_elect(end));
tq = siggyfun(coeffs_elect,tt);
plot(tt,tq,'Color',rgb(84, 110, 122))

axis square
xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')))
ylabel('pDetect')
ylim([0 1])


subplot(2,2,4); hold on; title('Elect dPrime')
SetFont('Arial', 18)

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 'Color', rgb(198, 40, 40), 'LineStyle', '-')
plot(block_struct(i).ElectDT_daily{:,1}, block_struct(i).ElectDT_daily{:,3}, 'Color', c(i,:),'LineStyle', ':', 'LineWidth', 2)

plot(tt,elect_dprime_coeffs,'Color',rgb(84, 110, 122))

lp = 0.2;
mp = 0.45;

[~, up] = min(abs(elect_dprime_coeffs-dprime_threshold));
plot([0 tt(up) tt(up)], [dprime_threshold, dprime_threshold, -1], 'Color',rgb(26, 35, 126),'LineStyle', '--')
text(25,2,(sprintf('%.0f',tt(up))), 'Color', rgb(26, 35, 126));

[~, ll_p] = min(abs(elect_dprime_coeffs-lp));
plot([0 tt(ll_p) tt(ll_p)], [lp, lp, -1],'Color', rgb(103, 58, 183), 'LineStyle', '--')
text(25,1,(sprintf('%.0f',tt(ll_p))), 'Color', rgb(103, 58, 183));

[~, mm_p] = min(abs(elect_dprime_coeffs-mp));
plot([0 tt(mm_p) tt(mm_p)], [mp, mp,-1], 'Color', rgb(156, 39, 176),'LineStyle', '--')
 text(25,1.5,(sprintf('%.0f',tt(mm_p))), 'Color', rgb(156, 39, 176));

axis square
xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')))
ylabel('d''')
ylim([-1 5])
xlim([0 30])

end
