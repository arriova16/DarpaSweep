%Darpa Sweep Mechanical 
%goals I want to be able pull files and be able to formatt them here
%I also want to be able to save those formatted files and analyze them

data_folder = 'B:\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_22and24\SweepTask\1_22-1_29';
% data_folder ='B:\ProjectFolders\DARPA\Data\RawData\Whistlepig\Electrode_6and15\SweepTask\Training';

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

%% putting things into block - will need to concat response tables?

for i = 1:length(data)
    %then take dprime and pdetect and use charles function for coeffs
    %create function that includes coeffs 
    %go over this looks weird

    for n =1:length(block_struct)

        [MechDetect_DT] = AnalyzeMechTable(data.MechDetectTable);
        % [dbd_mech_dt{n}]= AnalyzeMechTable(block_struct(n).MechRT);
         x_mech = MechDetect_DT.MechAmp;
         y_mech_dprime = MechDetect_DT.dPrime;

         [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime, 'NumCoeffs', 4,'Constraints', [0, 200; -5, 5]);
             % 'PlotFit', true, 'CoeffInit', [1,15,NaN,NaN], 'NumCoeffs', 3, 'EnableBackup', false);


        %analysis for electrical table
  
        [ElectDetect_DT] = AnalyzeElectTable(data.ElectDetectTable);
        % [dbd_elect_dt{n}] = AnalyzeElectTable(block_struct(n).ElectRT);
        x_elect = ElectDetect_DT.StimAmp;
        y_elect = ElectDetect_DT.dPrime;
         
         %coeffs are the issues/ constraints
   
        [~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', 4,'CoeffInit', [1,15,NaN,NaN]);
     % 'NumCoeffs', 4,'Constraints', [0, 500; -10, 10]'CoeffInit', [0,200,NaN,NaN]
 
    end
end

%% Plotting
%      c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
       sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4);
 %was getting error with above sigmoid because it was expecting 4 but only
 %giving 3
% sigfun = GetSigmoid(2); 
% somesig = GetSigmoid(2);

%FIX X AXIS ON PLOTS

dprime_threshold = 1.35;
 SetFont('Arial', 18)
%plotting Mech Detection pdetect and dprime

figure;
subplot(2,2,1); hold on ; title('Mech pDetect')
%coeffs incorrect/ maybe constraints wrong

scatter(MechDetect_DT.MechAmp,MechDetect_DT.pDetect , 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp,MechDetect_DT.pDetect,'Color', [.1 .1 .1], 'LineStyle', ':')
axis square
% trouble with coeffs plotting
 xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('pDetect','FontSize',18) 
 ylim([0 1])
subplot(2,2,2); 
hold on; title('Mech dPrime')

scatter(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle',':')
axis square
 xq = linspace(0, x_mech(end));
 %this is the problem
 yq = sigfun(coeffs,xq);
 [~, b] = min(abs(yq-dprime_threshold));
 plot(xq,yq)
 plot([0 xq(b) xq(b)], [dprime_threshold, dprime_threshold, 0], 'LineStyle','--')
 xlabel(sprintf('Amplitude (mm)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('d''','FontSize',18)
 ylim([0 5])


subplot(2,2,3); hold on; title('Elect pDetect')

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 'Color', [.1 .1 .1], 'LineStyle',':')
axis square
 xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('pDetect','FontSize',18)
ylim([0 1])

 subplot(2,2,4); hold on; title('Elect dPrime')

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle',':')
axis square

 ll = 0.45;
 mm = 0.9;

 tt = linspace(0,x_elect(end));
 tq = sigfun(coeffs_elect,tt);

 [~, np] = min(abs(tq-dprime_threshold));
 plot([0 tt(np) tt(np)], [dprime_threshold, dprime_threshold, 0], 'LineStyle', '--')

  [~, ll_np] = min(abs(tq-ll));
  plot([0 tt(ll_np) tt(ll_np)], [ll, ll, 0], 'LineStyle', '--')
  
  [~, mm_np] = min(abs(tq-mm));
  plot([0 tt(mm_np) tt(mm_np)], [mm, mm, 0], 'LineStyle', '--')
 
  
  plot(tt,tq)
 xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('d''','FontSize',18)
 ylim([0 5])

%% plotting dprime and pdetect day by day

