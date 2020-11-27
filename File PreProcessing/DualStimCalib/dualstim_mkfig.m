clear all

%----------- VARIABLE TO SET ----------
%set mice ID
mouse = {'M0863','M0936','M0941','M0913','M0934','M0935'};
%set MFB voltage used during dual
voltmfbpag = [5.5 7; 3 3; 7 8.5; 4 5; NaN NaN; NaN NaN];

%----------- SAVING PARAMETERS ----------
% Outputs
dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/StimMFBWake/';
if ~exist(dirout, 'dir')
    mkdir(dirout);
end
sav=1;      % Do you want to save a figure? Y=1; N=0


%-----------hardcoded DATA ----------
voltage = [0 0.5 1 1.5 2 2.5 ...
           3 3.5 4 4.5 5 5.5 ...
           6 6.5 7 7.5 8 8.5 ...
           9 9.5 10];


%dualnbr = [8 NaN 23 NaN 29 NaN 23 NaN 28 NaN 13 9 2 3 NaN 2 NaN NaN NaN NaN NaN;...
%                29 29 31 23 15 1 0 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];

%M0863
mfbnbr(1,:) = [NaN; NaN; 1; NaN; 3; NaN; ...
                 10; NaN; 22; NaN; 34; NaN; ...
                 36; NaN; 36; NaN; 36; NaN; ...
                 NaN; NaN; NaN];

dualnbr(1,:) = [NaN; NaN; 23; NaN; 29; NaN;  ...
                  23; NaN; 28; NaN; 13; 9;...
                  2; 3; 0; NaN; NaN; NaN;...
                  NaN; NaN; NaN];
% dualnbr(1,:,:) = [NaN NaN; 1 23; 2 29; 3 23; 4 28; ...
%                   5 13; 5.5 9; 6 2; 6.5 3; 7 0; ... 
%                   NaN NaN; NaN NaN;; NaN NaN; NaN NaN; NaN NaN];
              
%M0936
mfbnbr(2,:) = [0; NaN; 3; NaN; 14; 25; ...
                 31; 28; 26; NaN; NaN; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(2,:) = [29; 29; 31; 23; 15; 1;...  
                0; NaN; NaN; NaN; NaN; NaN; ...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];             
% dualnbr(2,:,:) = [0 29; 0.5 29; 1 31; 1.5 23; 2 15; ...
%                   2.5 1; 3 0; NaN NaN; NaN NaN; NaN NaN; ...
%                   NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];

%M0941
mfbnbr(3,:) = [2; NaN; 5; 16; 1; 7; ...
                 17; 20; 11; 18; 17; 22; ...
                 24; 24; 25; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(3,:) = [24; NaN; 22; NaN; 20; NaN;...
                  25; NaN; 20; NaN; 22; NaN;... 
                  18; NaN; 14; 8; 5; 0; ...
                  NaN; NaN; NaN;];             
% dualnbr(3,:,:) = [0 24; 1 22; 2 20; 3 25; 4 20;  ...
%                   5 22; 6 18; 7 14; 7.5 8; 8 5; ...
%                   8.5 0; NaN NaN; NaN NaN; NaN NaN; NaN NaN];

%M0913
mfbnbr(4,:) = [5; NaN; 3; NaN; 1; NaN; ...
                 2; NaN; 33; 25; 31; NaN; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(4,:,:) = [31; NaN; 21; NaN; 23; NaN;...
                  33; NaN; 9; NaN; 1; NaN; ...
                  NaN; NaN; NaN; NaN; NaN; NaN;...
                    NaN; NaN; NaN];  
% dualnbr(4,:,:) = [0 31; 1 21; 2 23; 3 33; 4 9;  ...
%                   5 1; NaN NaN; NaN NaN; NaN NaN; NaN NaN; ...
%                   NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];
% NOTE: see special case script for this mouse. After dual at 5V it started
% to go back even though it was aversive...

%M0934
mfbnbr(5,:) = [2; NaN; 1; NaN; 9; 16; ...
                 25; 32; 31; 32; 33; 34; ...
                 NaN; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(5,:) = [NaN; NaN; NaN; NaN; NaN; NaN;... 
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];  
%NOTE: no dual was done on this mouse. Issue with nosepoke (Marcelo).

%M0935
mfbnbr(6,:) = [7; NaN; 7; NaN; 8; NaN; ...
                 17; 23; 25; 34; 31; 27; ...
                 28; NaN; NaN; NaN; NaN; NaN; ...
                 NaN; NaN; NaN];
dualnbr(6,:) = [NaN; NaN; NaN; NaN; NaN; NaN;... 
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN; NaN; NaN; NaN;...
                NaN; NaN; NaN];               
% dualnbr(6,:,:) = [NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN;  ...
%                   NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN; ...
%                   NaN NaN; NaN NaN; NaN NaN; NaN NaN; NaN NaN];
 %NOTE: no dual was done on this mouse. Issue with nosepoke (Marcelo).

% Get normalized value for voltage 
for i=1:length(mouse)
    %mfb   
    idv = find(sum(~isnan(mfbnbr(i,:)),1) > 0, 1 , 'last');
    maxv(i)=voltage(idv);     
    norm_volt(i,1:length(voltage))=voltage/maxv(i);
    %dual
    idvd = find(sum(~isnan(dualnbr(i,:)),1) >0, 1 , 'last');
    if ~isempty(idvd)
        maxdv(i)=voltage(idvd);     
        norm_dvolt(i,1:length(voltage))=voltage/maxdv(i);
    else
        norm_dvolt(i,1:length(voltage))= NaN;
    end
end 


              
%% FIGURES

% MFB
figure
    for i=1:length(mouse)
        y = mfbnbr(i,:); %nbr stim
        x = voltage(:); %voltage
        idx = ~any(isnan(y),1);
        
        plot(x(idx),y(idx),'-o')
        hold on
    end
    ylim([0 40]);
    xlim([0 8.5]);
    title('Self-stimulation during MFB calibration')
    xlabel('MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend(mouse, 'Location','southeast')
 
    print([dirout '/fig_mfbcalib'], '-dpng', '-r300');

%Normalized MFB
figure
    for i=1:length(mouse)
        y = mfbnbr(i,:); %nbr stim
        x = norm_volt(i,:); %voltage
        idx = ~any(isnan(y),1);
        
        plot(x(idx),y(idx),'-o')
        hold on
    end
    ylim([0 40]);
%     xlim([0 1]);
    title('Self-stimulation during MFB calibration')
    xlabel('Normalized MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend(mouse, 'Location','southeast')
 
    print([dirout '/fig_mfbcalib_norm'], '-dpng', '-r300');    
    
% DUAL
figure
    for i=1:length(mouse)
        y = dualnbr(i,:); %nbr stim
        x = voltage(:); %voltage
        idx = ~any(isnan(y),1);
        
        plot(x(idx),y(idx),'-o')
        hold on
    end
    ylim([0 40]);
    xlim([0 8.5]);
    
    title('Self-stimulation during dual stimultion (MFB+PAG)')
    xlabel('PAG voltage') 
    ylabel('Nbr of self-stimulation')
    legend({[mouse{1} ' - MFB: ' num2str(voltmfbpag(1)) 'V'], ...
            [mouse{2} ' - MFB: ' num2str(voltmfbpag(2)) 'V'], ...
            [mouse{3} ' - MFB: ' num2str(voltmfbpag(3)) 'V'], ...
            [mouse{4} ' - MFB: ' num2str(voltmfbpag(4)) 'V']}, ...
            'Location','northeast')
 
    print([dirout '/fig_dualcalib'], '-dpng', '-r300');
    
%Normalized Dual
figure
    for i=1:length(mouse)
        y = dualnbr(i,:); %nbr stim
        x = norm_dvolt(i,:); %voltage
        idx = ~any(isnan(y),1);
        
        plot(x(idx),y(idx),'-o')
        hold on
    end
    ylim([0 40]);
%     xlim([0 1]);
    title('Self-stimulation during dual calibration')
    xlabel('Normalized MFB voltage') 
    ylabel('Nbr of self-stimulation')
    legend({[mouse{1} ' - MFB: ' num2str(voltmfbpag(1)) 'V'], ...
            [mouse{2} ' - MFB: ' num2str(voltmfbpag(2)) 'V'], ...
            [mouse{3} ' - MFB: ' num2str(voltmfbpag(3)) 'V'], ...
            [mouse{4} ' - MFB: ' num2str(voltmfbpag(4)) 'V']}, ...
            'Location','northeast')
 
    print([dirout '/fig_dualcalib_norm'], '-dpng', '-r300');      